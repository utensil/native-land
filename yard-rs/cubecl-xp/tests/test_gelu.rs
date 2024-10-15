use std::env::VarError;

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


// stack backtrace:
//    0: rust_begin_unwind
//              at /rustc/9322d183f45e0fd5a509820874cc5ff27744a479/library/std/src/panicking.rs:665:5
//    1: core::panicking::panic_fmt
//              at /rustc/9322d183f45e0fd5a509820874cc5ff27744a479/library/core/src/panicking.rs:74:14
//    2: wgpu::backend::wgpu_core::default_error_handler
//              at /Users/runner/.cargo/registry/src/index.crates.io-6f17d22bba15001f/wgpu-22.1.0/src/backend/wgpu_core.rs:3411:5
//    3: core::ops::function::Fn::call
//              at /rustc/9322d183f45e0fd5a509820874cc5ff27744a479/library/core/src/ops/function.rs:79:5
//    4: <alloc::boxed::Box<F,A> as core::ops::function::Fn<Args>>::call
//              at /rustc/9322d183f45e0fd5a509820874cc5ff27744a479/library/alloc/src/boxed.rs:2468:9
//    5: wgpu::backend::wgpu_core::ErrorSinkRaw::handle_error
//              at /Users/runner/.cargo/registry/src/index.crates.io-6f17d22bba15001f/wgpu-22.1.0/src/backend/wgpu_core.rs:3397:17
//    6: wgpu::backend::wgpu_core::ContextWgpuCore::handle_error
//              at /Users/runner/.cargo/registry/src/index.crates.io-6f17d22bba15001f/wgpu-22.1.0/src/backend/wgpu_core.rs:296:9
//    7: wgpu::backend::wgpu_core::ContextWgpuCore::handle_error_nolabel
//              at /Users/runner/.cargo/registry/src/index.crates.io-6f17d22bba15001f/wgpu-22.1.0/src/backend/wgpu_core.rs:308:9
//    8: <wgpu::backend::wgpu_core::ContextWgpuCore as wgpu::context::Context>::device_create_query_set
//              at /Users/runner/.cargo/registry/src/index.crates.io-6f17d22bba15001f/wgpu-22.1.0/src/backend/wgpu_core.rs:1410:13
//    9: <T as wgpu::context::DynContext>::device_create_query_set
//              at /Users/runner/.cargo/registry/src/index.crates.io-6f17d22bba15001f/wgpu-22.1.0/src/context.rs:2381:33
//   10: wgpu::Device::create_query_set
//              at /Users/runner/.cargo/registry/src/index.crates.io-6f17d22bba15001f/wgpu-22.1.0/src/lib.rs:3195:13
//   11: cubecl_wgpu::compute::server::WgpuServer::new
//              at /Users/runner/.cargo/git/checkouts/cubecl-aa41a28b39b598f9/e98de7c/crates/cubecl-wgpu/src/compute/server.rs:141:24
//   12: cubecl_wgpu::runtime::create_client
//              at /Users/runner/.cargo/git/checkouts/cubecl-aa41a28b39b598f9/e98de7c/crates/cubecl-wgpu/src/runtime.rs:144:18
//   13: <cubecl_wgpu::runtime::WgpuRuntime as cubecl_core::runtime::Runtime>::client::{{closure}}
//              at /Users/runner/.cargo/git/checkouts/cubecl-aa41a28b39b598f9/e98de7c/crates/cubecl-wgpu/src/runtime.rs:47:13
//   14: cubecl_runtime::base::ComputeRuntime<Device,Server,Channel>::client
//              at /Users/runner/.cargo/git/checkouts/cubecl-aa41a28b39b598f9/e98de7c/crates/cubecl-runtime/src/base.rs:55:42
//   15: cubecl_xp::gelu_shader
//              at ./src/lib.rs:26:18
//   16: test_gelu::test_shader
//              at ./tests/test_gelu.rs:29:16
//   17: test_gelu::test_shader::{{closure}}
//              at ./tests/test_gelu.rs:28:17
//   18: core::ops::function::FnOnce::call_once
//              at /rustc/9322d183f45e0fd5a509820874cc5ff27744a479/library/core/src/ops/function.rs:250:5
//   19: core::ops::function::FnOnce::call_once
//              at /rustc/9322d183f45e0fd5a509820874cc5ff27744a479/library/core/src/ops/function.rs:250:5

#[cfg(feature = "wgpu")]
#[cfg(not(target_os = "windows"))]
#[test]
fn test_shader() {
    let ci = std::env::var("CI");
    let os = std::env::consts::OS;
    // skip for macos CI
    let should_run= match ci {
        Err(VarError::NotPresent) => true,
        _ => os != "macos",
    };
    if should_run {
        let wgsl = cubecl_xp::gelu_shader::<cubecl::wgpu::WgpuRuntime>(&Default::default());
        assert_eq!(wgsl, include_str!("fixtures/gelu.wgsl"));
    }
}
