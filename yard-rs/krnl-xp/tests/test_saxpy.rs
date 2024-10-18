use krnl_xp::run_saxpy;

#[test]
fn test_saxpy() {
    // if environment variable `CI` is present, and the OS is linux, skip the test
    // I still wish to run the test on runpod
    if std::env::var("CI").is_ok() && std::env::consts::OS == "linux" {
        return;
    }
    let res = run_saxpy();
    assert!(res.is_ok());
    let y = res.unwrap();
    assert_eq!(y, vec![2.0]);
}
