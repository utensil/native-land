extern crate assert_cli;

#[allow(dead_code)]
pub fn run_example(name: &str) -> assert_cli::Assert {
    // assert_cli::Assert::command(&["cargo", "run", "--example", name])
    assert_cli::Assert::example(name)
}

#[allow(dead_code)]
pub fn build(name: &str) -> assert_cli::Assert {
    assert_cli::Assert::command(&["rustc", name])
}
