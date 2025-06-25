extern crate chrono;

#[cfg(test)]
mod run_cpp_test {
    use chrono::Utc;
    use rust_cpp::run_cpp::*;

    #[test]
    fn test_printf() {
        printf();
    }

    #[test]
    fn test_now() {
        let expected_seconds = Utc::now().timestamp();
        assert_eq!(expected_seconds, now());
    }

    // Run it with
    // cargo test --test run_cpp_test -- --nocapture
    #[test]
    fn test_double() {
        double();
    }
}
