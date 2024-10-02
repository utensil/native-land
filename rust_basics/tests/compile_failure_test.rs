mod utils;

#[cfg(test)]
mod compile_failure_test {
    use super::utils::build;

    #[test]
    fn change_immutable() {
        build("compile_failures/change_immutable.rs")
            .fails() // .fails_with(101) sometimes 1
            .stderr()
            .contains("error[E0596]: cannot borrow `*some_string` as mutable, as it is behind a `&` reference")
            .unwrap();
    }
}