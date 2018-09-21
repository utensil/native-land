mod utils;

#[cfg(test)]
mod compile_failure_test {
    use super::utils::build;

    #[test]
    fn change_immutable() {
        build("compile_failures/change_immutable.rs")
            .fails_with(101)
            .stderr()
            .contains("error[E0596]: cannot borrow immutable borrowed content `*some_string` as mutable")
            .unwrap();
    }
}