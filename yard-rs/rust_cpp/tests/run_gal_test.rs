extern crate chrono;

#[cfg(test)]
mod run_gal_test {
    use rust_cpp::run_gal::*;

    #[test]
    fn test_hello() {
        hello_pga();
    }
}
