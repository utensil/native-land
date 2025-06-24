extern crate futures;

use futures::Future;
use std::io;

mod future_input;
mod future_timeout;

use future_input::ReadLine;
use future_timeout::Timeout;
use std::time::Duration;

// Following the video https://www.youtube.com/watch?v=Yzvxnky7syM
// Read also https://aturon.github.io/blog/2016/09/07/futures-design/
fn main() {
    println!("May I have your name?");

    match read_name() {
        Err(_) => println!("Hello, whatever!"),
        Ok(name) => println!("Hello, {}!", name.trim()),
    }
}

fn read_name() -> io::Result<String> {
    let result = ReadLine::new() // futures::empty()
        .select(Timeout::new(Duration::from_secs(5), || {
            io::Error::new(io::ErrorKind::Other, "timeout elapsed".to_string())
        }))
        .wait();

    match result {
        Ok((name, _)) => Ok(name),
        Err((e, _)) => Err(e),
    }
}
