extern crate assert_cli;

pub fn run_example(name: &str) -> assert_cli::Assert {
    // assert_cli::Assert::command(&["cargo", "run", "--example", name])
    assert_cli::Assert::example(name)
}
