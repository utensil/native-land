
extern crate cpp_build;

fn main() {
    let libs = std::env::current_dir().unwrap().join("libs");
    let include_gal = libs.join("gal/public");
    let include_sga = libs.join("sga");

    cpp_build::Config::new()
        .flag("-std=c++20")
        .include(include_gal)
        .include(include_sga)
        .build("src/lib.rs");

    // suppress cargo rerun for edits
    println!("cargo:rerun-if-changed=src/run_cpp.rs");
}
