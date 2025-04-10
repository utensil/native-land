#![deny(warnings)]

extern crate futures;
extern crate libc;
extern crate libloading as lib;
extern crate rand;
extern crate tokio;

#[macro_use]
extern crate quick_error;

use std::fs::OpenOptions;
extern crate serde;
// extern crate serde_json;
extern crate serde_yaml;

#[macro_use]
extern crate serde_derive;

#[cfg(windows)]
extern crate kernel32;
#[cfg(windows)]
extern crate systray;
#[cfg(windows)]
extern crate winapi;
// #[cfg(windows)] use winapi::{MENUITEMINFOW, UINT};
// #[cfg(windows)] use user32;
// #[cfg(windows)] use winapi::windef::{HWND, HMENU, HICON, HBRUSH, HBITMAP};
// #[cfg(windows)] use winapi::winnt::{LPCWSTR};
// #[cfg(windows)] use winapi::minwindef::{DWORD, WPARAM, LPARAM, LRESULT, HINSTANCE, TRUE, PBYTE};
// #[cfg(windows)] use winapi::winuser::{WNDCLASSW, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, LR_DEFAULTCOLOR};

use std::env;
use std::error::Error;
use std::fmt::Display;
use std::io;
use std::net::{Shutdown, SocketAddr};
use std::sync::{Arc, Mutex};

use tokio::io::{copy, shutdown};
use tokio::net::{TcpListener, TcpStream};
use tokio::prelude::*;
use tokio::runtime::Runtime;

use std::collections::{HashMap, HashSet};
use std::net::UdpSocket;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::mpsc::channel;
use std::thread;
use std::time::Duration;

// use futures::Stream;

// Adapted from https://github.com/tokio-rs/tokio/blob/master/examples/proxy.rs
// 1. Change result.unwrap() to ?
// 2. Add context to error
// 3. use result.unwrap_or_else() to handle error message
// 4. omit intermediate variables to have a better future style
// 5. alias Arc<Mutex<T>> to Shared<T> and add make_shared<T>
// 6. add a branch adapted from https://tokio.rs/docs/getting-started/hello-world/

fn with_context<T, E>(result: Result<T, E>, msg: &str) -> Result<T, String>
where
    E: Display,
{
    result.map_err(|err| format!("{}({})", err, msg))
}

pub trait ErrWithMsg<T>
where
    Self: std::marker::Sized,
{
    fn map_err_with_msg(self, msg: String) -> Result<T, String>;

    fn unless(self, msg: String) -> Result<T, String> {
        self.map_err_with_msg(msg)
    }
    fn should(self, msg: String) -> Result<T, String> {
        self.map_err_with_msg(msg)
    }

    fn context(self, msg: String) -> Result<T, String> {
        self.map_err_with_msg(msg)
    }
}

impl<T, E> ErrWithMsg<T> for Result<T, E>
where
    E: Display,
{
    fn map_err_with_msg(self, msg: String) -> Result<T, String> {
        self.map_err(|err| format!("{}: {}", msg, err))
    }
}

impl<T> ErrWithMsg<T> for Option<T> {
    fn map_err_with_msg(self, msg: String) -> Result<T, String> {
        if let Some(t) = self {
            Ok(t)
        } else {
            Err(format!("{}: expecting Some, got None", msg))
        }
    }
}

type Shared<T> = Arc<Mutex<T>>;

fn make_shared<T>(t: T) -> Shared<T> {
    Arc::new(Mutex::new(t))
}

fn print_help() -> Result<(), Box<dyn Error>> {
    println!("Usage:");
    println!("rustry help");
    println!("rustry hello listen_ip listen_port_start listen_port_stop");
    // println!("rustry hosts");
    println!("rustry tcp_proxy listen_ip listen_port forward_ip forward_port");
    println!("rustry udp_proxy listen_ip listen_port forward_ip forward_port");
    println!("rustry ping target_ip");
    println!("rustry tray");
    // println!("rustry test dst_ip:dst_port");

    Ok(())
}

fn send_hello(socket: TcpStream) -> Result<(), io::Error> {
    println!("accepted socket; addr={:?}", socket.peer_addr().unwrap());

    let connection =
        tokio::io::write_all(socket, "HTTP/1.1 200 OK\r\n\r\nHello world!\r\n").then(|res| {
            println!("wrote message; success={:?}", res.is_ok());
            Ok(())
        });

    // Spawn a new task that processes the socket:
    tokio::spawn(connection);

    Ok(())
}

fn spawn_hello_task(
    rt: &mut Runtime,
    listen_ip_str: String,
    listen_port: u16,
) -> Result<(), Box<dyn Error>> {
    let listen_addr_str = format!("{}:{}", listen_ip_str, listen_port);
    let listen_addr = listen_addr_str
        .parse::<SocketAddr>()
        .unless(format!("failed to listen to {}", listen_addr_str))?;

    let listener = with_context(TcpListener::bind(&listen_addr), &listen_addr_str)?;
    println!("Listening on: {}", listen_addr);

    let task = listener.incoming().for_each(send_hello).map_err(|err| {
        // All tasks must have an `Error` type of `()`. This forces error
        // handling and helps avoid silencing failures.
        //
        // In our example, we are only going to log the error to STDOUT.
        println!("accept error = {:?}", err);
    });

    rt.spawn(task);

    Ok(())
}

fn hello_main() -> Result<(), Box<dyn Error>> {
    let listen_ip_str = env::args().nth(2).unwrap_or("127.0.0.1".to_string());
    let listen_port_start_str = env::args().nth(3).unwrap_or("80".to_string());
    let listen_port_stop_str = env::args().nth(4).unwrap_or(listen_port_start_str.clone());
    let listen_port_start = listen_port_start_str.parse::<u16>()?;
    let listen_port_stop = listen_port_stop_str.parse::<u16>()?;

    let mut rt = Runtime::new()?;

    for listen_port in listen_port_start..=listen_port_stop {
        spawn_hello_task(&mut rt, listen_ip_str.clone(), listen_port)?;
    }

    rt.shutdown_on_idle()
        .wait()
        .map_err(|err| format!("{:?}", err))?;

    Ok(())
}

quick_error! {
    #[derive(Debug)]
    pub enum AppError {
        OsError(error_msg: String) {
            description(error_msg)
            display(r#"{}"#, error_msg)
        }

        IoError(error_msg: String) {
            description(error_msg)
            display(r#"{}"#, error_msg)
        }
    }
}

#[allow(dead_code)]
#[cfg(windows)]
unsafe fn get_win_os_error(msg: &str) -> AppError {
    AppError::OsError(format!("{}: {}", &msg, kernel32::GetLastError()))
}

#[cfg(windows)]
use std::ffi::OsStr;
#[cfg(windows)]
use std::os::windows::ffi::OsStrExt;
#[cfg(windows)]
use winapi::ctypes::*;
#[cfg(windows)]
use winapi::shared::guiddef::GUID;
#[cfg(windows)]
use winapi::shared::minwindef::*;
#[cfg(windows)]
use winapi::shared::ntdef::*;
#[cfg(windows)]
use winapi::shared::windef::*;
#[cfg(windows)]
use winapi::um::shellapi::*;

// Adapted from https://github.com/qdot/systray-rs/blob/master/src/api/win32/mod.rs
#[cfg(windows)]
unsafe fn get_nid_struct(hwnd: &HWND) -> NOTIFYICONDATAW {
    NOTIFYICONDATAW {
        cbSize: std::mem::size_of::<NOTIFYICONDATAW>() as DWORD,
        hWnd: *hwnd,
        uID: 0x1 as UINT,
        uFlags: 0 as UINT,
        uCallbackMessage: 0 as UINT,
        hIcon: 0 as HICON,
        szTip: [0_u16; 128],
        dwState: 0 as DWORD,
        dwStateMask: 0 as DWORD,
        szInfo: [0 as WCHAR; 256],
        u: std::mem::transmute_copy(&(0)),
        szInfoTitle: [0 as WCHAR; 64],
        dwInfoFlags: 0 as UINT,
        guidItem: GUID {
            Data1: 0 as c_ulong,
            Data2: 0 as c_ushort,
            Data3: 0 as c_ushort,
            Data4: [0 as c_uchar; 8],
        },
        hBalloonIcon: 0 as HICON,
    }
}

#[cfg(windows)]
fn to_absolute_path(relative_path_str: String) -> Result<String, Box<dyn Error>> {
    let relative_path = std::path::PathBuf::from(relative_path_str);
    let mut absolute_path = std::env::current_dir()?;
    absolute_path.push(relative_path);

    let ret = absolute_path
        .to_str()
        .context(format!("{:?}", absolute_path))?;

    Ok(ret.to_string())
}

#[cfg(windows)]
fn tray_main() -> Result<(), Box<dyn Error>> {
    let mut app;
    match systray::Application::new() {
        Ok(w) => app = w,
        Err(_) => panic!("Can't create window!"),
    }

    let icon_path = to_absolute_path("res/SysReqMet.ico".to_string())?;
    println!("icon_path is {}", icon_path);
    app.set_icon_from_file(&icon_path).ok();

    #[allow(dead_code)]
    unsafe {
        struct MyWindowInfo {
            pub hwnd: HWND,
            pub hinstance: HINSTANCE,
            pub hmenu: HMENU,
        }

        struct MyWindow {
            pub info: MyWindowInfo,
        }

        struct MyApplication {
            pub window: MyWindow,
        }

        fn to_wstring(str: &str) -> Vec<u16> {
            OsStr::new(str)
                .encode_wide()
                .chain(Some(0))
                .collect::<Vec<_>>()
        }

        fn copy_into_wstring(dst: &mut [WCHAR], src: &str) {
            let src_wstr = to_wstring(src);
            let len = std::cmp::min(dst.len(), src_wstr.len());

            dst[0..len].copy_from_slice(&src_wstr[0..len]);
        }

        let pub_app: MyApplication = std::mem::transmute_copy(&app);
        let hwnd = pub_app.window.info.hwnd;

        let mut nid = get_nid_struct(&hwnd);

        nid.uID = 0x1;
        nid.uFlags = NIF_INFO;

        copy_into_wstring(&mut nid.szInfoTitle, "将进酒");
        copy_into_wstring(
            &mut nid.szInfo,
            r###"君不见，黄河之水天上来，奔流到海不复回。
君不见，高堂明镜悲白发，朝如青丝暮成雪。
人生得意须尽欢，莫使金樽空对月。
天生我材必有用，千金散尽还复来。
烹羊宰牛且为乐，会须一饮三百杯。
岑夫子，丹丘生，将进酒，杯莫停。
与君歌一曲，请君为我倾耳听。
钟鼓馔玉不足贵，但愿长醉不复醒。
古来圣贤皆寂寞，惟有饮者留其名。
陈王昔时宴平乐，斗酒十千恣欢谑。
主人何为言少钱，径须沽取对君酌。
五花马，千金裘，呼儿将出换美酒，与尔同销万古愁。"###,
        );
        nid.dwInfoFlags = NIIF_INFO;

        if Shell_NotifyIconW(NIM_MODIFY, &mut nid as *mut NOTIFYICONDATAW) == 0 {
            return Err(Box::new(get_win_os_error(
                "Error displaying a balloon notification",
            )));
        }

        // winapi::um::shellapi::Shell_NotifyIconW(winapi::um::shellapi::NIM_ADD, nid);
    }

    app.wait_for_message();

    Ok(())
}

#[cfg(not(windows))]
fn tray_main() -> Result<(), Box<dyn Error>> {
    println!("tray is only implemented for Windows.");

    Ok(())
}

#[cfg(windows)]
fn ping_main() -> Result<(), Box<dyn Error>> {
    let target_addr_str = env::args().nth(2).unwrap_or("127.0.0.1".to_string());
    // let target_addr = with_context(listen_addr_str.parse::<SocketAddr>(), &listen_addr_str)?;

    let mut _reactor = with_context(
        tokio::reactor::Reactor::new(),
        "tokio::reactor::Reactor::new()",
    )?;

    let lib_iphlpapi = lib::Library::new("Iphlpapi.dll")?;

    println!("Pinging {}......", target_addr_str);

    unsafe {
        // Windows Data Types
        // https://msdn.microsoft.com/en-us/library/windows/desktop/aa383751(v=vs.85).aspx

        // https://msdn.microsoft.com/en-us/library/windows/desktop/aa366045(v=vs.85).aspx
        #[allow(non_snake_case)]
        let _IcmpCreateFile: lib::Symbol<
            unsafe extern "C" fn() -> winapi::shared::ntdef::HANDLE,
        > = lib_iphlpapi.get(b"IcmpCreateFile")?;

        // https://msdn.microsoft.com/en-us/library/windows/desktop/aa366050%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
        #[allow(non_snake_case)]
        let _IcmpSendEcho: lib::Symbol<
            unsafe extern "C" fn(
                winapi::shared::ntdef::HANDLE,
                std::os::raw::c_ulong, //winapi::shared::inaddr::IN_ADDR,
                *const libc::c_char,   //winapi::shared::minwindef::LPVOID,
                winapi::shared::minwindef::WORD,
                winapi::shared::ntdef::HANDLE, // _In_opt_ PIP_OPTION_INFORMATION
                *mut libc::c_void,             //winapi::shared::minwindef::LPVOID,
                winapi::shared::minwindef::DWORD,
                winapi::shared::minwindef::DWORD,
            ) -> winapi::shared::minwindef::DWORD,
        > = lib_iphlpapi.get(b"IcmpSendEcho")?;

        // #[allow(non_snake_case)]
        // let _IcmpParseReplies : lib::Symbol<unsafe extern fn(
        //     * mut libc::c_void,
        //     winapi::shared::minwindef::DWORD,
        // ) -> winapi::shared::minwindef::DWORD> = lib_iphlpapi.get(b"IcmpParseReplies")?;

        let ipaddr_str = std::ffi::CString::new(target_addr_str)?;
        let ipaddr: std::os::raw::c_ulong = winapi::um::winsock2::inet_addr(ipaddr_str.as_ptr());

        if ipaddr == winapi::shared::ws2def::INADDR_NONE {
            return Err(Box::new(std::io::Error::other(
                "ipaddr == winapi::shared::ws2def::INADDR_NONE",
            )));
        }

        let ipaddr_struct =
            std::mem::transmute::<std::os::raw::c_ulong, winapi::shared::inaddr::in_addr>(ipaddr);

        libc::puts(winapi::um::winsock2::inet_ntoa(ipaddr_struct) as *const libc::c_char);

        let h_icmp = _IcmpCreateFile();

        if std::ptr::eq(h_icmp, winapi::um::handleapi::INVALID_HANDLE_VALUE) {
            return Err(Box::new(std::io::Error::other(
                "h_icmp == winapi::um::handleapi::INVALID_HANDLE_VALUE",
            )));
        }

        #[repr(C, packed)]
        struct IpOptionInformation {
            ttl: std::os::raw::c_uchar,
            tos: std::os::raw::c_uchar,
            flags: std::os::raw::c_uchar,
            options_size: std::os::raw::c_uchar,
            options_data: *const std::os::raw::c_uchar,
        }

        #[repr(C, packed)]
        struct IcmpEchoReply {
            address: std::os::raw::c_ulong, //winapi::shared::inaddr::in_addr,
            status: std::os::raw::c_ulong,
            rtt: std::os::raw::c_ulong,
            data_size: std::os::raw::c_ushort,
            reserved: std::os::raw::c_ushort,
            data: *const libc::c_char,
            info: IpOptionInformation,
        }

        let request = String::from("12345");
        let request_len = request.len();
        let buf_size = std::mem::size_of::<IcmpEchoReply>() + request_len + 16;
        let timeout = 1000;
        // let mut buffer = Vec::with_capacity(buf_size as usize);
        // let p_buffer = buffer.as_mut_ptr();

        let send_data = std::ffi::CString::new(request)?;

        libc::puts(send_data.as_ptr() as *const libc::c_char);

        println!(
            "h_icmp:\t\t{:016x}\nipaddr:\t\t{:016x}\nsend_data:\t{:016x}",
            h_icmp as usize,
            ipaddr as usize,
            send_data.as_ptr() as usize
        );

        let p_buffer = libc::malloc(buf_size);

        let ret_val = _IcmpSendEcho(
            h_icmp,
            ipaddr,
            send_data.as_ptr() as *const libc::c_char,
            request_len as u16,
            std::ptr::null_mut(),
            p_buffer,
            buf_size as u32,
            timeout,
        );

        println!("ret_val = {}", ret_val);

        println!("LastError = {}", kernel32::GetLastError() as u32);

        let p_reply = std::mem::transmute::<*mut libc::c_void, *const IcmpEchoReply>(p_buffer);

        let reply = &*p_reply;

        let reply_address = std::mem::transmute::<
            std::os::raw::c_ulong,
            winapi::shared::inaddr::in_addr,
        >(reply.address);

        println!("[REPLY]");
        println!("address:");
        libc::puts(winapi::um::winsock2::inet_ntoa(reply_address) as *const libc::c_char);
        println!("status: {}", reply.status as i32);
        println!("rtt: {}", reply.rtt as i32);
        println!("data_size: {}", reply.data_size as i32);
        println!("data:");
        libc::puts(reply.data);
        println!("reserved: {}", reply.reserved as i32);
        println!("ttl: {}", reply.info.ttl as i32);

        // let count = _IcmpParseReplies(p_buffer, buf_size as u32) as u32;

        // println!("count:{}", count);

        // let str_buffer = p_buffer as *const libc::c_char;
        // libc::puts(str_buffer);

        for i in 0..buf_size {
            let p0 = p_buffer as usize;
            let p = (p0 + i) as *const libc::c_char;
            let v = *p as u8;

            print!("{:02x}", v);

            if (i + 1) % 8 == 0 {
                println!();
            } else if (i + 1) % 4 == 0 {
                print!(" ");
            }
        }
    }

    Ok(())
}

#[cfg(not(windows))]
fn ping_main() -> Result<(), Box<dyn Error>> {
    println!("ping is only implemented for Windows.");

    Ok(())
}

#[derive(Serialize, Deserialize)]
struct ForwardAddressPair {
    listen_ip: String,
    listen_port: i32,
    forward_ip: String,
    forward_port: i32,
}

#[derive(Serialize, Deserialize)]
enum ForwardProtocol {
    Tcp,
    Udp,
}

type Ips = Vec<std::net::IpAddr>;

#[derive(Serialize, Deserialize)]
struct ForwardItem {
    proto: ForwardProtocol,
    addr: ForwardAddressPair,
    accepts: Option<Ips>,
}

impl ForwardItem {
    pub fn new(
        proto: ForwardProtocol,
        listen_ip: &str,
        listen_port: i32,
        forward_ip: &str,
        forward_port: i32,
        accepts: &Option<Ips>,
    ) -> ForwardItem {
        ForwardItem {
            proto,
            addr: ForwardAddressPair {
                listen_ip: listen_ip.to_string(),
                listen_port,
                forward_ip: forward_ip.to_string(),
                forward_port,
            },
            accepts: accepts.clone(),
        }
    }

    pub fn forward(&self) -> Result<(), Box<dyn Error>> {
        let addr = &(self.addr);
        match self.proto {
            ForwardProtocol::Tcp => tcp_forward(
                &addr.listen_ip,
                addr.listen_port,
                &addr.forward_ip,
                addr.forward_port,
                &self.accepts,
            ),
            ForwardProtocol::Udp => udp_forward(
                &addr.listen_ip,
                addr.listen_port,
                &addr.forward_ip,
                addr.forward_port,
                &self.accepts,
            ),
        }
    }
}

// fn hosts_main -> Result<(), Box<dyn Error>> {

// }

// Adapted from https://github.com/neosmart/tcpproxy/blob/master/src/main.rs
fn tcp_proxy_main() -> Result<(), Box<dyn Error>> {
    let listen_ip = env::args().nth(2).unwrap_or("127.0.0.1".to_string());
    let listen_port_str = env::args().nth(3).unwrap_or("80".to_string());
    let listen_port = listen_port_str.parse()?;
    let forward_ip = env::args().nth(4).unwrap_or("127.0.0.1".to_string());
    let forward_port_str = env::args().nth(5).unwrap_or("8080".to_string());
    let forward_port = forward_port_str.parse()?;

    let forward_item = ForwardItem::new(
        ForwardProtocol::Tcp,
        &listen_ip,
        listen_port,
        &forward_ip,
        forward_port,
        &None,
    );
    forward_item.forward()?;

    Ok(())
}

fn tcp_forward(
    listen_ip: &str,
    listen_port: i32,
    forward_ip: &str,
    forward_port: i32,
    accepts: &Option<Ips>,
) -> Result<(), Box<dyn Error>> {
    let listen_addr_str = format!("{}:{}", listen_ip, listen_port);
    let listen_addr = with_context(listen_addr_str.parse::<SocketAddr>(), &listen_addr_str)?;
    let forward_addr_str = format!("{}:{}", forward_ip, forward_port);
    let forward_addr = with_context(forward_addr_str.parse::<SocketAddr>(), &forward_addr_str)?;

    // Create a Tcp listener which will listen for incoming connections.
    let listener = with_context(TcpListener::bind(&listen_addr), &listen_addr_str)?;

    let mut accepted_ips: HashSet<std::net::IpAddr> = HashSet::new();
    let mut accepted_ips_desc = String::new();
    if let Some(ref ips) = accepts {
        accepted_ips_desc = "\nFor only: \n".to_string();
        accepted_ips = ips.iter().copied().collect();
        accepted_ips.iter().for_each(|accepted_ip| {
            accepted_ips_desc.push_str(&format!("- {}", &accepted_ip));
        });
    }

    println!(
        "[Tcp] {} -> {}{}",
        listen_addr, forward_addr, accepted_ips_desc
    );

    let done = listener
        .incoming()
        .map_err(|e| println!("error accepting socket; error = {:?}", e))
        .for_each(move |client| {
            let peer_ip = client.peer_addr().unwrap().ip();
            if !accepted_ips.is_empty() && !accepted_ips.contains(&peer_ip) {
                let rejection = tokio::io::write_all(
                    client,
                    "HTTP/1.1 403 Forbidden
Content-Type: text/plain; charset=UTF-8
Content-Length: 13
Connection: close

403 Forbidden",
                )
                .then(move |_res| {
                    println!("Incoming client rejected: {:?}", peer_ip);
                    Ok(())
                });

                tokio::spawn(rejection);
            } else {
                let proxy =
                    TcpStream::connect(&forward_addr)
                        .and_then(move |server| {
                            // Create separate read/write handles for the Tcp clients that we're
                            // proxying data between. Note that typically you'd use
                            // `AsyncRead::split` for this operation, but we want our writer
                            // handles to have a custom implementation of `shutdown` which
                            // actually calls `TcpStream::shutdown` to ensure that EOF is
                            // transmitted properly across the proxied connection.
                            //
                            // As a result, we wrap up our client/server manually in arcs and
                            // use the impls below on our custom `MyTcpStream` type.
                            let client_reader = ProxyTcpStream::new(client);
                            let client_writer = client_reader.clone();
                            let server_reader = ProxyTcpStream::new(server);
                            let server_writer = server_reader.clone();

                            // Copy the data (in parallel) between the client and the server.
                            // After the copy is done we indicate to the remote side that we've
                            // finished by shutting down the connection.
                            let client_to_server = copy(client_reader, server_writer).and_then(
                                |(n, _, server_writer)| shutdown(server_writer).map(move |_| n),
                            );

                            let server_to_client = copy(server_reader, client_writer).and_then(
                                |(n, _, client_writer)| shutdown(client_writer).map(move |_| n),
                            );

                            client_to_server.join(server_to_client)
                        })
                        .map(move |(from_client, from_server)| {
                            println!(
                                "client wrote {} bytes and received {} bytes",
                                from_client, from_server
                            );
                        })
                        .map_err(|e| {
                            // Don't panic. Maybe the client just disconnected too soon.
                            println!("error: {}", e);
                        });

                tokio::spawn(proxy);
            }
            Ok(())
        });

    tokio::run(done);

    Ok(())
}

fn udp_proxy_main() -> Result<(), Box<dyn Error>> {
    let listen_ip = env::args().nth(2).unwrap_or("127.0.0.1".to_string());
    let listen_port_str = env::args().nth(3).unwrap_or("80".to_string());
    let listen_port = listen_port_str.parse()?;
    let forward_ip = env::args().nth(4).unwrap_or("127.0.0.1".to_string());
    let forward_port_str = env::args().nth(5).unwrap_or("8080".to_string());
    let forward_port = forward_port_str.parse()?;

    let forward_item = ForwardItem::new(
        ForwardProtocol::Udp,
        &listen_ip,
        listen_port,
        &forward_ip,
        forward_port,
        &None,
    );
    forward_item.forward()?;

    Ok(())
}

static mut REF_CHILD: Option<Shared<std::process::Child>> = None;

fn proxies_main() -> Result<(), Box<dyn Error>> {
    // let tcp_listen_ip = "127.0.0.1";
    // let tcp_forward_ip = "127.0.0.1";
    // let udp_listen_ip = "127.0.0.1";
    // let udp_forward_ip = "127.0.0.1";
    // let tcp_listen_port = 80;
    // let tcp_forward_port = 8080;
    // let udp_listen_port = 81;
    // let udp_forward_port = 8081;

    // let forward_config = vec![
    //     ForwardItem::new(ForwardProtocol::Tcp, &tcp_listen_ip, tcp_listen_port, &tcp_forward_ip, tcp_forward_port),
    //     ForwardItem::new(ForwardProtocol::Udp, &udp_listen_ip, udp_listen_port, &udp_forward_ip, udp_forward_port)
    // ];

    // let forward_config = vec![
    //     ForwardItem::new(ForwardProtocol::Tcp, "127.0.0.1", 80, "127.0.0.1", 8080),
    //     ForwardItem::new(ForwardProtocol::Udp, "127.0.0.1", 81, "127.0.0.1", 8081)
    // ];

    // let file = OpenOptions::new()
    //         .read(true)
    //         .write(true)
    //         .create(true)
    //         .open("config.yml")?;

    // serde_yaml::to_writer(&file, &forward_config)?;

    let file_name = env::args().nth(2).unwrap_or("config.yml".to_string());

    let file = OpenOptions::new().read(true).open(file_name)?;

    let forward_config: Vec<ForwardItem> = serde_yaml::from_reader(file)?;

    let threads = forward_config
        .into_iter()
        .map(|forward_item| thread::spawn(move || forward_item.forward().unwrap()))
        .collect::<Vec<_>>();

    for t in threads {
        t.join().unwrap();
    }

    Ok(())
}

fn spawn_main() -> Result<(), Box<dyn Error>> {
    use std::process::Command;

    let command = env::args().nth(2).unwrap_or("ping".to_string());

    let _t = thread::spawn(|| {
        let child = Command::new(command)
            // .arg("file.txt")
            .spawn()
            .expect("failed to execute child");
        unsafe {
            REF_CHILD = Some(make_shared(child));

            // if let Some(ref mut child) = REF_CHILD {
            //     let output = child.lock().unwrap()
            //         .wait_with_output()
            //         .expect("failed to wait on child").clone();

            //     println!("success status: {}", output.status.success());
            //     let sout = String::from_utf8(output.stdout).expect("Not UTF-8");
            //     let serr = String::from_utf8(output.stderr).expect("Not UTF-8");
            //     println!("stdout: {}", sout);
            //     println!("stderr: {}", serr);
            // }
        }

        loop {
            std::thread::sleep(Duration::from_millis(1000));
        }
    });

    loop {
        unsafe {
            if let Some(ref child) = REF_CHILD {
                println!("Killing......");
                child
                    .lock()
                    .unwrap()
                    .kill()
                    .expect("command wasn't running");
                return Ok(());
            } else {
                println!("Waiting......");
            }
        }

        std::thread::sleep(Duration::from_millis(1));
    }

    // let _res = t.join();
}

fn main() {
    let args: Vec<String> = std::env::args().collect();

    let arg_branch = args.get(1).cloned().unwrap_or("help".to_string());

    match &arg_branch[..] {
        "tcp_proxy" => tcp_proxy_main(),
        "udp_proxy" => udp_proxy_main(),
        "proxies" => proxies_main(),
        "hello" => hello_main(),
        "ping" => ping_main(),
        "tray" => tray_main(),
        "spawn" => spawn_main(),
        // "hosts" => {
        //     hosts_main()
        // }
        "help" => print_help(),
        _ => print_help(),
    }
    .unwrap_or_else(|err| println!("{}", err));
}

// The following are adpated from https://github.com/neosmart/tcpproxy/blob/master/src/main.rs

// This is a custom type used to have a custom implementation of the
// `AsyncWrite::shutdown` method which actually calls `TcpStream::shutdown` to
// notify the remote end that we're done writing.
#[derive(Clone)]
struct ProxyTcpStream {
    _handle: Shared<TcpStream>,
}

impl ProxyTcpStream {
    fn new(tcp_stream: TcpStream) -> Self {
        ProxyTcpStream {
            _handle: make_shared(tcp_stream),
        }
    }

    fn handle(&mut self) -> &Shared<TcpStream> {
        &self._handle
    }
}

impl io::Read for ProxyTcpStream {
    fn read(&mut self, buf: &mut [u8]) -> io::Result<usize> {
        self.handle().lock().unwrap().read(buf)
    }
}

impl io::Write for ProxyTcpStream {
    fn write(&mut self, buf: &[u8]) -> io::Result<usize> {
        self.handle().lock().unwrap().write(buf)
    }

    fn flush(&mut self) -> io::Result<()> {
        Ok(())
    }
}

impl AsyncRead for ProxyTcpStream {}

impl AsyncWrite for ProxyTcpStream {
    fn shutdown(&mut self) -> Poll<(), io::Error> {
        self.handle().lock().unwrap().shutdown(Shutdown::Write)?;
        Ok(().into())
    }
}

// End of https://github.com/neosmart/tcpproxy/blob/master/src/main.rs

// The following are adapted from https://github.com/neosmart/udpproxy/blob/master/src/main.rs
const TIMEOUT: u64 = 10 * 1000; // 10s
static mut DEBUG: bool = true;

fn debug(msg: String) {
    let debug: bool;
    unsafe {
        debug = DEBUG;
    }

    if debug {
        println!("{}", msg);
    }
}

fn udp_forward(
    listen_ip: &str,
    listen_port: i32,
    forward_ip: &str,
    forward_port: i32,
    accepts: &Option<Ips>,
) -> Result<(), Box<dyn Error>> {
    let listen_addr = format!("{}:{}", listen_ip, listen_port);
    let local = UdpSocket::bind(&listen_addr)?;

    let forward_addr = format!("{}:{}", forward_ip, forward_port);

    let mut accepted_ips: HashSet<std::net::IpAddr> = HashSet::new();
    let mut accepted_ips_desc = String::new();
    if let Some(ref ips) = accepts {
        accepted_ips_desc = "\nFor only: \n".to_string();
        accepted_ips = ips.iter().copied().collect();
        accepted_ips.iter().for_each(|accepted_ip| {
            accepted_ips_desc.push_str(&format!("- {}", &accepted_ip));
        });
    }

    println!(
        "[Udp] {} -> {}{}",
        listen_addr, forward_addr, accepted_ips_desc
    );

    let responder = local.try_clone()?;
    let (main_sender, main_receiver) = channel::<(_, Vec<u8>)>();
    thread::spawn(move || {
        // debug(format!("Started new thread to deal out responses to clients"));
        loop {
            let (dest, buf) = main_receiver.recv().unwrap();
            let to_send = buf.as_slice();
            responder.send_to(to_send, dest).unwrap_or_else(|_| {
                panic!(
                    "Failed to forward response from upstream server to client {}",
                    dest
                )
            });
        }
    });

    let mut client_map = HashMap::new();
    let mut buf = [0; 64 * 1024];
    loop {
        let (num_bytes, src_addr) = local.recv_from(&mut buf).expect("Didn't receive data");

        println!("{}", src_addr);

        let peer_ip = src_addr.ip();
        if !accepted_ips.is_empty() && !accepted_ips.contains(&peer_ip) {
            println!("Incoming client rejected: {:?}", peer_ip);
            continue;
        }

        //we create a new thread for each unique client
        let mut remove_existing = false;
        loop {
            debug(format!("Received packet from client {}", src_addr));

            let mut ignore_failure = true;
            let client_id = format!("{}", src_addr);

            if remove_existing {
                debug("Removing existing forwarder from map.".to_string());
                client_map.remove(&client_id);
            }

            let sender = client_map.entry(client_id.clone()).or_insert_with(|| {
                //we are creating a new listener now, so a failure to send shoud be treated as an error
                ignore_failure = false;

                let local_send_queue = main_sender.clone();
                let (sender, receiver) = channel::<Vec<u8>>();
                let forward_addr_copy = forward_addr.clone();
                thread::spawn(move || {
                    //regardless of which port we are listening to, we don't know which interface or IP
                    //address the remote server is reachable via, so we bind the outgoing
                    //connection to 0.0.0.0 in all cases.
                    let temp_outgoing_addr = format!("0.0.0.0:{}", 1024 + rand::random::<u16>());
                    debug(format!(
                        "Establishing new forwarder for client {} on {}",
                        src_addr, &temp_outgoing_addr
                    ));
                    let upstream_send = UdpSocket::bind(&temp_outgoing_addr).unwrap_or_else(|_| panic!("Failed to bind to transient address {}",
                            &temp_outgoing_addr));
                    let upstream_recv = upstream_send
                        .try_clone()
                        .expect("Failed to clone client-specific connection to upstream!");

                    let mut timeouts: u64 = 0;
                    let timed_out = Arc::new(AtomicBool::new(false));

                    let local_timed_out = timed_out.clone();
                    thread::spawn(move || {
                        let mut from_upstream = [0; 64 * 1024];
                        upstream_recv
                            .set_read_timeout(Some(Duration::from_millis(TIMEOUT + 100)))
                            .unwrap();
                        loop {
                            match upstream_recv.recv_from(&mut from_upstream) {
                                Ok((bytes_rcvd, _)) => {
                                    let to_send = from_upstream[..bytes_rcvd].to_vec();
                                    local_send_queue.send((src_addr, to_send))
                                        .expect("Failed to queue response from upstream server for forwarding!");
                                }
                                Err(_) => {
                                    if local_timed_out.load(Ordering::Relaxed) {
                                        debug(format!("Terminating forwarder thread for client {} due to timeout", src_addr));
                                        break;
                                    }
                                }
                            };
                        }
                    });

                    loop {
                        match receiver.recv_timeout(Duration::from_millis(TIMEOUT)) {
                            Ok(from_client) => {
                                upstream_send.send_to(from_client.as_slice(), &forward_addr_copy)
                                    .unwrap_or_else(|_| panic!("Failed to forward packet from client {} to upstream server!", src_addr));
                                timeouts = 0; //reset timeout count
                            }
                            Err(_) => {
                                timeouts += 1;
                                if timeouts >= 10 {
                                    debug(format!(
                                        "Disconnecting forwarder for client {} due to timeout",
                                        src_addr
                                    ));
                                    timed_out.store(true, Ordering::Relaxed);
                                    break;
                                }
                            }
                        };
                    }
                });
                sender
            });

            let to_send = buf[..num_bytes].to_vec();
            match sender.send(to_send) {
                Ok(_) => {
                    break;
                }
                Err(_) => {
                    if !ignore_failure {
                        panic!(
                            "Failed to send message to datagram forwarder for client {}",
                            client_id
                        );
                    }
                    //client previously timed out
                    debug(format!(
                        "New connection received from previously timed-out client {}",
                        client_id
                    ));
                    remove_existing = true;
                    continue;
                }
            }
        }
    }
}

// end of https://github.com/neosmart/udpproxy/blob/master/src/main.rs
