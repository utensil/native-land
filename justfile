test:
    cargo test --workspace

build:
    cargo build --workspace

prep:
    # https://rust-analyzer.github.io/manual.html#installation
    rustup component add rust-src
    rustup component add rust-analyzer

prep-nightly:
    rustup toolchain install nightly
    rustup component add rust-src --toolchain nightly
    rustup component add rust-analyzer --toolchain nightly

test-nightly:
    cargo +nightly test --workspace

build-nightly:
    cargo +nightly build --workspace

nightly: prep-nightly test-nightly
