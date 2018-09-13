#[macro_use]
extern crate maplit;

extern crate rust_basics;

#[cfg(test)]
mod fibonacci_test {
    use std::collections::HashMap;

    use rust_basics::fibonacci::*;

    fn fib_map() -> HashMap<i32, i64> {
        hashmap!{
            0 => 0,
            1 => 1,
            7 => 13
        }
    }

    #[test]
    fn test_fib_recursive() {
        let fib = fib_map();

        for (i, v) in fib {
            assert_eq!(v, fib_recursive(i));
        }
    }

    #[test]
    fn test_fib_loop() {
        let fib = fib_map();

        for (i, v) in fib {
            assert_eq!(v, fib_loop(i));
        }
    }
}
