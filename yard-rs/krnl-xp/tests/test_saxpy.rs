use krnl_xp::run_saxpy;

#[test]
fn test_saxpy() {
    let res = run_saxpy();
    assert!(res.is_ok());
    let y = res.unwrap();
    assert_eq!(y, vec![2.0]);
}
