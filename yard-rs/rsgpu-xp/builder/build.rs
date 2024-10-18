use std::error::Error;

// #[rustversion::not(nightly(2024-04-24))]
// compile_error!(
//     "builder requires nightly-2024-04-24, install with rustup:
// rustup toolchain install nightly-2024-04-24
// rustup component add --toolchain nightly-2024-04-24 rust-src rustc-dev llvm-tools-preview"
// );

fn main() -> Result<(), Box<dyn Error>> {
    Ok(())
}