use rsgpu_xp::compute;

#[test]
fn test_compute() {
    let result = compute::start();
    assert_eq!(result[&409631], 130);
    assert_eq!(result[&956926], u32::MAX);
}
