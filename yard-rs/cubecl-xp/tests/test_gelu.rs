
#[cfg(not(target_os = "windows"))]
#[test]
fn test_launch() {
    #[cfg(feature = "wgpu")]
    let result = cubecl_xp::gelu_launch::<cubecl::wgpu::WgpuRuntime>(&Default::default());
    #[cfg(feature = "cuda")]
    let result = cubecl_xp::gelu_launch::<cubecl::cuda::CudaRuntime>(&Default::default());

    // pretty_assertions::assert_eq!(vec![-0.1587, 0.0000, 0.8413, 5.0000], result);
    // test float equality for result
    for (a, b) in result.iter().zip(vec![-0.1587, 0.0000, 0.8413, 5.0000].iter()) {
        assert!((a - b).abs() < 1e-2);
    }
}

// --- TRY 1 STDERR:        cubecl-xp::test_gelu test_shader ---
// thread 'test_shader' panicked at /Users/runner/.cargo/registry/src/index.crates.io-6f17d22bba15001f/wgpu-22.1.0/src/backend/wgpu_core.rs:3411:5:
// wgpu error: Validation Error
// 
// Caused by:
//   In Device::create_query_set
//     Features Features(TIMESTAMP_QUERY) are required but not enabled on the device

#[cfg(feature = "wgpu")]
#[cfg(not(target_os = "windows"))]
#[test]
fn test_shader() {
    let wgsl = cubecl_xp::gelu_shader::<cubecl::wgpu::WgpuRuntime>(&Default::default());
    assert_eq!(wgsl, include_str!("fixtures/gelu.wgsl"));
}
