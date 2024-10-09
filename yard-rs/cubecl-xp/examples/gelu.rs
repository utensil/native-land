fn main() {
    // #[cfg(feature = "wgpu")]
    let output = cubecl_xp::gelu_launch::<cubecl::wgpu::WgpuRuntime>(&Default::default());
    println!("Executed gelu => {output:?}, expected [-0.1587, 0.0000, 0.8413, 5.0000]");
}
