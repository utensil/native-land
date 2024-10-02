build:
    cargo build --workspace

test:
    cargo test --workspace

prep:
    # https://rust-analyzer.github.io/manual.html#installation
    rustup component add rust-src
    rustup component add rust-analyzer
