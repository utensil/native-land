extern crate futures;

use futures::{Future, Poll};
use std::io;
use std::sync::mpsc::{self, Receiver};
use std::thread;

pub struct ReadLine {
    recv: Receiver<io::Result<String>>,
}

impl Default for ReadLine {
    fn default() -> Self {
        Self::new()
    }
}

impl ReadLine {
    pub fn new() -> ReadLine {
        let (tx, rx) = mpsc::channel();

        thread::spawn(move || tx.send(read_line()));

        ReadLine { recv: rx }
    }
}

impl Future for ReadLine {
    type Item = String;
    type Error = io::Error;

    fn poll(&mut self) -> Poll<Self::Item, Self::Error> {
        use futures::task;
        use futures::Async;

        match self.recv.try_recv() {
            Err(_) => {
                task::current().notify();
                Ok(Async::NotReady)
            }
            Ok(Ok(line)) => Ok(Async::Ready(line)),
            Ok(Err(e)) => Err(e),
        }
    }
}

fn read_line() -> io::Result<String> {
    use std::io::BufRead;

    let input = io::stdin();
    let mut locked = input.lock();
    let mut buf = String::default();

    match locked.read_line(&mut buf) {
        Ok(_) => Ok(buf),
        Err(e) => Err(e),
    }
}

// suppress cargo test error E0601
#[allow(dead_code)]
fn main() {}
