use std::env;
use std::error::Error;
use std::os::macos::raw::stat;
use std::path::PathBuf;

fn main() -> Result<(), Box<dyn Error>> {
    // let target_os = std::env::var("CARGO_CFG_TARGET_OS")?;
    // let target_arch = std::env::var("CARGO_CFG_TARGET_ARCH")?;
    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:rerun-if-env-changed=CARGO_CFG_TARGET_OS");
    println!("cargo:rerun-if-env-changed=CARGO_CFG_TARGET_ARCH");

    // // cargo install krnlc --git https://github.com/charles-r-earp/krnl --rev 96b5d97205ba2cd08ad65e99d758c26349c31b24
    // let status = std::process::Command::new("cargo")
    //     .args([
    //         "install",
    //         "krnlc",
    //         "--git",
    //         "https://github.com/charles-r-earp/krnl",
    //         "--rev",
    //         "96b5d97205ba2cd08ad65e99d758c26349c31b24"
    //     ])
    //     .status()?;

    // if !status.success() {
    //     if let Some(code) = status.code() {
    //         std::process::exit(code);
    //     } else {
    //         std::process::exit(1);
    //     }
    // }

    // let status = std::process::Command::new("krnlc")
    //     // .args([])
    //     .stderr(std::process::Stdio::inherit())
    //     .stdout(std::process::Stdio::inherit())
    //     .status()?;

    // if !status.success() {
    //     if let Some(code) = status.code() {
    //         std::process::exit(code);
    //     } else {
    //         std::process::exit(1);
    //     }
    // }

    Ok(())
}