pub fn fib_recursive(n: i32) -> i64 {
    match n {
        0 => 0,
        1 => 1,
        _ => fib_recursive(n - 1) + fib_recursive(n - 2),
    }
}

pub fn fib_loop(n: i32) -> i64 {
    let mut f1 = 0;
    let mut f2 = 1;
    match n {
        0 => 0,
        1 => 1,
        _ => {
            for _ in 2..=n {
                let sum = f1 + f2;
                f1 = f2;
                f2 = sum;
            }
            f2
        }
    }
}
