use super::*;

#[test]
fn test_print_help() {
    assert!(print_help().is_ok());
}

#[test]
fn test_hello_main() {
    std::env::set_var("RUST_LOG", "debug");
    assert!(hello_main().is_err()); // Should fail without proper args
}