#[macro_use] extern crate quicli;
use quicli::prelude::*;

#[derive(Debug, StructOpt)]
struct Rustry {
  /// Pass many times for more log output
  #[structopt(long = "verbose", short = "v", parse(from_occurrences))]
  verbosity: u8,
  #[structopt(subcommand)]  // Note that we mark a field as a subcommand
  cmd: RustryCommand
}

#[derive(Debug, StructOpt)]
enum RustryCommand {
  #[structopt(name = "tcp_proxy", about="TODO")]
  TcpProxy {
    #[structopt(default_value = "127.0.0.1", help="TODO")]
    listen_ip: String,
    #[structopt(default_value = "8080", help="TODO")]
    listen_port: i32,
    #[structopt(default_value = "127.0.0.1", help="TODO")]
    forward_ip: String,
    #[structopt(default_value = "80", help="TODO")]
    forward_port: i32
  }
}

main!(|args: Rustry, log_level: verbosity| {
  println!("{:?}", args);
});