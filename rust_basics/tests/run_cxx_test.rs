extern crate rust_basics;
extern crate chrono;

#[cfg(test)]
mod run_cxx_test {
    use rust_basics::run_cxx::*;
    use chrono::Utc;

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
    // cargo test --test run_cxx_test -- --nocapture
    #[test]
    fn test_double() {
        double();
    }
}