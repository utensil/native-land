mod utils;

#[cfg(test)]
mod stdin_test {
    use super::utils::run_example;

    #[test]
    fn add_read_numbers() {
        run_example("stdin").stdin("2 5").stdout().is("7").unwrap();
    }
}
