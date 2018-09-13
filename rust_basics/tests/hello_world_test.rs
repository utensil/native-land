mod utils;

#[cfg(test)]
mod hello_world_test {
    use super::utils::run_example;

    #[test]
    fn output_hello_world() {
        run_example("hello_world")
            .stdout()
            .is("Hello, world!")
            .unwrap();
    }
}
