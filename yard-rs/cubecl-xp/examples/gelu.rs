fn main() {
    #[cfg(feature = "wgpu")]
    type R = cubecl::wgpu::WgpuRuntime;
    #[cfg(feature = "cuda")]
    type R = cubecl::cuda::CudaRuntime;

    let wgsl = cubecl_xp::gelu_shader::<R>(&Default::default());
    println!("gelu shader => \n\n{}", wgsl);
    let output = cubecl_xp::gelu_launch::<R>(&Default::default());
    println!("Executed gelu => {output:?}, expected [-0.1587, 0.0000, 0.8413, 5.0000]");
}
