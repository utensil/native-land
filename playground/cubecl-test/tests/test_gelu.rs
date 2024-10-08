#[cfg(not(target_os = "windows"))]
#[test]
fn test() {
    // #[cfg(feature = "wgpu")]
    let result = cubecl_test::gelu_launch::<cubecl::wgpu::WgpuRuntime>(&Default::default());
    // pretty_assertions::assert_eq!(vec![-0.1587, 0.0000, 0.8413, 5.0000], result);
    // test float equality for result
    for (a, b) in result.iter().zip(vec![-0.1587, 0.0000, 0.8413, 5.0000].iter()) {
        assert!((a - b).abs() < 1e-2);
    }
}

