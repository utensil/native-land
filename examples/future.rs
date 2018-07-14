extern crate futures;

use std::io;
use futures::Future;

mod future_timeout;
mod future_input;

use std::time::Duration;
use future_timeout::Timeout;
use future_input::ReadLine;

// Following the video https://www.youtube.com/watch?v=Yzvxnky7syM
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