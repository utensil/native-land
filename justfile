# to install just:
# run: curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

export HOMEBREW_NO_AUTO_UPDATE := "1"
export BINSTALL_DISABLE_TELEMETRY := "true"
export RUST_BACKTRACE :="1"
# export RUSTC_WRAPPER := "sccache"
# export CARGO_BUILD_JOBS := "4"

# export MAMBA_ROOT_PREFIX := clean(join(justfile_directory(), "..", "micromamba"))
# mm_packages := join(MAMBA_ROOT_PREFIX, "envs", "tch-rs", "lib", "python3.11", "site-packages")
# export LIBTORCH := join(mm_packages , "torch")

LIBTORCH_PREFIX := clean(join(justfile_directory() , ".."))
export LIBTORCH := join(LIBTORCH_PREFIX, "libtorch")
env_sep := if os() == "windows" { ";" } else { ":" }
export PATH := join(LIBTORCH, "lib") + env_sep + env_var("PATH")
export LIBTORCH_BYPASS_VERSION_CHECK := "1"
export DYLD_LIBRARY_PATH := join(LIBTORCH, "lib")
export DYLD_FALLBACK_LIBRARY_PATH := join(LIBTORCH, "lib")

default:
    just list

# this could be used to do quick ad hoc checks in CI with little installed
check:
    just
    echo "LIBTORCH=$LIBTORCH"
    echo "PATH=$PATH"
    echo "DYLD_LIBRARY_PATH={{DYLD_LIBRARY_PATH}}"

prep-ci:
    just prep-cache
    just prep-tch

[linux]
ci: prep-ci
    just clippy
    just cov
    # cd yard-rs/krnl-xp && just test
    # just cov-rsgpu

[macos]
[windows]
ci: prep-ci
    just clippy
    just test
    # cd yard-rs/krnl-xp && just test
    # just test-rsgpu

[group('rust'), no-cd]
test:
    #!/usr/bin/env bash
    set -e
    echo "Running nextest run --no-fail-fast --retries 2 in bevy-xp"
    cd yard-rs/bevy-xp && cargo nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running nextest run --no-fail-fast --retries 2 in candle-xp"
    cd yard-rs/candle-xp && cargo nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running nextest run --no-fail-fast --retries 2 in clifford-xp"
    cd yard-rs/clifford-xp && cargo nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running nextest run --no-fail-fast --retries 2 in lists"
    cd yard-rs/lists && cargo nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running nextest run --no-fail-fast --retries 2 in rust_cpp"
    cd yard-rs/rust_cpp && cargo nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running nextest run --no-fail-fast --retries 2 in cubecl-xp"
    cd yard-rs/cubecl-xp && cargo nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running nextest run --no-fail-fast --retries 2 in tch-xp"
    cd yard-rs/tch-xp && cargo nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running nextest run --no-fail-fast --retries 2 in dx-xp"
    cd yard-rs/dx-xp && cargo nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running nextest run --no-fail-fast --retries 2 in rust_basics"
    cd yard-rs/rust_basics && cargo nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running nextest run --no-fail-fast --retries 2 in rustry"
    cd yard-rs/rustry && cargo nextest run --no-fail-fast --retries 2
    cd ../..

[group('util'), no-cd]
list:
    just --list

[group('rust'), no-cd]
test-stable:
    #!/usr/bin/env bash
    set -e
    echo "Running +stable nextest run --no-fail-fast --retries 2 in bevy-xp"
    cd yard-rs/bevy-xp && cargo +stable nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +stable nextest run --no-fail-fast --retries 2 in candle-xp"
    cd yard-rs/candle-xp && cargo +stable nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +stable nextest run --no-fail-fast --retries 2 in clifford-xp"
    cd yard-rs/clifford-xp && cargo +stable nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +stable nextest run --no-fail-fast --retries 2 in lists"
    cd yard-rs/lists && cargo +stable nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +stable nextest run --no-fail-fast --retries 2 in rust_cpp"
    cd yard-rs/rust_cpp && cargo +stable nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +stable nextest run --no-fail-fast --retries 2 in cubecl-xp"
    cd yard-rs/cubecl-xp && cargo +stable nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +stable nextest run --no-fail-fast --retries 2 in tch-xp"
    cd yard-rs/tch-xp && cargo +stable nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +stable nextest run --no-fail-fast --retries 2 in dx-xp"
    cd yard-rs/dx-xp && cargo +stable nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +stable nextest run --no-fail-fast --retries 2 in rust_basics"
    cd yard-rs/rust_basics && cargo +stable nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +stable nextest run --no-fail-fast --retries 2 in rustry"
    cd yard-rs/rustry && cargo +stable nextest run --no-fail-fast --retries 2
    cd ../..

# [group('rust'), no-cd]
# prep-stable:
#     # https://rust-analyzer.github.io/manual.html#installation
#     rustup toolchain install stable
#     rustup component add rust-src
#     rustup component add rust-analyzer

# [group('rust'), no-cd]
# prep-nightly:
#     rustup toolchain install nightly
#     rustup component add rust-src --toolchain nightly
#     rustup component add rust-analyzer --toolchain nightly

[group('rust'), no-cd]
@test-nightly:
    #!/usr/bin/env bash
    set -e
    echo "Running +nightly nextest run --no-fail-fast --retries 2 in bevy-xp"
    cd yard-rs/bevy-xp && yes|cargo +nightly nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +nightly nextest run --no-fail-fast --retries 2 in candle-xp"
    cd yard-rs/candle-xp && yes|cargo +nightly nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +nightly nextest run --no-fail-fast --retries 2 in clifford-xp"
    cd yard-rs/clifford-xp && yes|cargo +nightly nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +nightly nextest run --no-fail-fast --retries 2 in lists"
    cd yard-rs/lists && yes|cargo +nightly nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +nightly nextest run --no-fail-fast --retries 2 in rust_cpp"
    cd yard-rs/rust_cpp && yes|cargo +nightly nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +nightly nextest run --no-fail-fast --retries 2 in cubecl-xp"
    cd yard-rs/cubecl-xp && yes|cargo +nightly nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +nightly nextest run --no-fail-fast --retries 2 in tch-xp"
    cd yard-rs/tch-xp && yes|cargo +nightly nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +nightly nextest run --no-fail-fast --retries 2 in dx-xp"
    cd yard-rs/dx-xp && yes|cargo +nightly nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +nightly nextest run --no-fail-fast --retries 2 in rust_basics"
    cd yard-rs/rust_basics && yes|cargo +nightly nextest run --no-fail-fast --retries 2
    cd ../..
    echo "Running +nightly nextest run --no-fail-fast --retries 2 in rustry"
    cd yard-rs/rustry && yes|cargo +nightly nextest run --no-fail-fast --retries 2
    cd ../..

[group('rust'), no-cd]
cov:
    #!/usr/bin/env bash
    set -e
    rm -f lcov.info
    echo "Running llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in bevy-xp"
    cd yard-rs/bevy-xp && yes|cargo llvm-cov --branch --lcov --output-path ../../lcov-bevy-xp.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in candle-xp"
    cd yard-rs/candle-xp && yes|cargo llvm-cov --branch --lcov --output-path ../../lcov-candle-xp.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in clifford-xp"
    cd yard-rs/clifford-xp && yes|cargo llvm-cov --branch --lcov --output-path ../../lcov-clifford-xp.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in lists"
    cd yard-rs/lists && yes|cargo llvm-cov --branch --lcov --output-path ../../lcov-lists.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in rust_cpp"
    cd yard-rs/rust_cpp && yes|cargo llvm-cov --branch --lcov --output-path ../../lcov-rust_cpp.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in cubecl-xp"
    cd yard-rs/cubecl-xp && yes|cargo llvm-cov --branch --lcov --output-path ../../lcov-cubecl-xp.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in tch-xp"
    cd yard-rs/tch-xp && yes|cargo llvm-cov --branch --lcov --output-path ../../lcov-tch-xp.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in dx-xp"
    cd yard-rs/dx-xp && yes|cargo llvm-cov --branch --lcov --output-path ../../lcov-dx-xp.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in rust_basics"
    cd yard-rs/rust_basics && yes|cargo llvm-cov --branch --lcov --output-path ../../lcov-rust_basics.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in rustry"
    cd yard-rs/rustry && yes|cargo llvm-cov --branch --lcov --output-path ../../lcov-rustry.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Merging coverage reports..."
    cat lcov-*.info > lcov.info 2>/dev/null || echo "SF:" > lcov.info  # Create empty coverage if no reports generated

[group('rust'), no-cd]
cov-nightly:
    #!/usr/bin/env bash
    set -e
    rm -f lcov.info
    echo "Running +nightly llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in bevy-xp"
    cd yard-rs/bevy-xp && yes|cargo +nightly llvm-cov --branch --lcov --output-path ../../lcov-bevy-xp.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running +nightly llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in candle-xp"
    cd yard-rs/candle-xp && yes|cargo +nightly llvm-cov --branch --lcov --output-path ../../lcov-candle-xp.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running +nightly llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in clifford-xp"
    cd yard-rs/clifford-xp && yes|cargo +nightly llvm-cov --branch --lcov --output-path ../../lcov-clifford-xp.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running +nightly llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in lists"
    cd yard-rs/lists && yes|cargo +nightly llvm-cov --branch --lcov --output-path ../../lcov-lists.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running +nightly llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in rust_cpp"
    cd yard-rs/rust_cpp && yes|cargo +nightly llvm-cov --branch --lcov --output-path ../../lcov-rust_cpp.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running +nightly llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in cubecl-xp"
    cd yard-rs/cubecl-xp && yes|cargo +nightly llvm-cov --branch --lcov --output-path ../../lcov-cubecl-xp.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running +nightly llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in tch-xp"
    cd yard-rs/tch-xp && yes|cargo +nightly llvm-cov --branch --lcov --output-path ../../lcov-tch-xp.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running +nightly llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in dx-xp"
    cd yard-rs/dx-xp && yes|cargo +nightly llvm-cov --branch --lcov --output-path ../../lcov-dx-xp.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running +nightly llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in rust_basics"
    cd yard-rs/rust_basics && yes|cargo +nightly llvm-cov --branch --lcov --output-path ../../lcov-rust_basics.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Running +nightly llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2 in rustry"
    cd yard-rs/rustry && yes|cargo +nightly llvm-cov --branch --lcov --output-path ../../lcov-rustry.info nextest --no-fail-fast --retries 2 || true
    cd ../..
    echo "Merging coverage reports..."
    cat lcov-*.info > lcov.info 2>/dev/null || echo "SF:" > lcov.info  # Create empty coverage if no reports generated

[group('rust'), no-cd]
clippy:
    #!/usr/bin/env bash
    set -e
    echo "Running clippy in bevy-xp"
    cd yard-rs/bevy-xp && cargo clippy
    cd ../..
    echo "Running clippy in candle-xp"
    cd yard-rs/candle-xp && cargo clippy
    cd ../..
    echo "Running clippy in clifford-xp"
    cd yard-rs/clifford-xp && cargo clippy
    cd ../..
    echo "Running clippy in lists"
    cd yard-rs/lists && cargo clippy
    cd ../..
    echo "Running clippy in rust_cpp"
    cd yard-rs/rust_cpp && cargo clippy
    cd ../..
    echo "Running clippy in cubecl-xp"
    cd yard-rs/cubecl-xp && cargo clippy
    cd ../..
    echo "Running clippy in tch-xp"
    cd yard-rs/tch-xp && cargo clippy
    cd ../..
    echo "Running clippy in dx-xp"
    cd yard-rs/dx-xp && cargo clippy
    cd ../..
    echo "Running clippy in rust_basics"
    cd yard-rs/rust_basics && cargo clippy
    cd ../..
    echo "Running clippy in rustry"
    cd yard-rs/rustry && cargo clippy
    cd ../..

[group('rust'), no-cd]
clippy-stable:
    #!/usr/bin/env bash
    set -e
    echo "Running +stable clippy in bevy-xp"
    cd yard-rs/bevy-xp && cargo +stable clippy
    cd ../..
    echo "Running +stable clippy in candle-xp"
    cd yard-rs/candle-xp && cargo +stable clippy
    cd ../..
    echo "Running +stable clippy in clifford-xp"
    cd yard-rs/clifford-xp && cargo +stable clippy
    cd ../..
    echo "Running +stable clippy in lists"
    cd yard-rs/lists && cargo +stable clippy
    cd ../..
    echo "Running +stable clippy in rust_cpp"
    cd yard-rs/rust_cpp && cargo +stable clippy
    cd ../..
    echo "Running +stable clippy in cubecl-xp"
    cd yard-rs/cubecl-xp && cargo +stable clippy
    cd ../..
    echo "Running +stable clippy in tch-xp"
    cd yard-rs/tch-xp && cargo +stable clippy
    cd ../..
    echo "Running +stable clippy in dx-xp"
    cd yard-rs/dx-xp && cargo +stable clippy
    cd ../..
    echo "Running +stable clippy in rust_basics"
    cd yard-rs/rust_basics && cargo +stable clippy
    cd ../..
    echo "Running +stable clippy in rustry"
    cd yard-rs/rustry && cargo +stable clippy
    cd ../..

[group('rust'), no-cd]
clippy-nightly:
    #!/usr/bin/env bash
    set -e
    echo "Running +nightly clippy in bevy-xp"
    cd yard-rs/bevy-xp && cargo +nightly clippy
    cd ../..
    echo "Running +nightly clippy in candle-xp"
    cd yard-rs/candle-xp && cargo +nightly clippy
    cd ../..
    echo "Running +nightly clippy in clifford-xp"
    cd yard-rs/clifford-xp && cargo +nightly clippy
    cd ../..
    echo "Running +nightly clippy in lists"
    cd yard-rs/lists && cargo +nightly clippy
    cd ../..
    echo "Running +nightly clippy in rust_cpp"
    cd yard-rs/rust_cpp && cargo +nightly clippy
    cd ../..
    echo "Running +nightly clippy in cubecl-xp"
    cd yard-rs/cubecl-xp && cargo +nightly clippy
    cd ../..
    echo "Running +nightly clippy in tch-xp"
    cd yard-rs/tch-xp && cargo +nightly clippy
    cd ../..
    echo "Running +nightly clippy in dx-xp"
    cd yard-rs/dx-xp && cargo +nightly clippy
    cd ../..
    echo "Running +nightly clippy in rust_basics"
    cd yard-rs/rust_basics && cargo +nightly clippy
    cd ../..
    echo "Running +nightly clippy in rustry"
    cd yard-rs/rustry && cargo +nightly clippy
    cd ../..

vcov: cov
    #!/usr/bin/env bash
    echo "Generating coverage reports for all projects..."
    cd yard-rs/bevy-xp && cargo llvm-cov report --ignore-filename-regex main.rs --html --open || true
    cd ../candle-xp && cargo llvm-cov report --ignore-filename-regex main.rs --html --open || true
    cd ../clifford-xp && cargo llvm-cov report --ignore-filename-regex main.rs --html --open || true
    cd ../lists && cargo llvm-cov report --ignore-filename-regex main.rs --html --open || true
    cd ../rust_cpp && cargo llvm-cov report --ignore-filename-regex main.rs --html --open || true
    cd ../cubecl-xp && cargo llvm-cov report --ignore-filename-regex main.rs --html --open || true
    cd ../tch-xp && cargo llvm-cov report --ignore-filename-regex main.rs --html --open || true
    cd ../dx-xp && cargo llvm-cov report --ignore-filename-regex main.rs --html --open || true
    cd ../rust_basics && cargo llvm-cov report --ignore-filename-regex main.rs --html --open || true
    cd ../rustry && cargo llvm-cov report --ignore-filename-regex main.rs --html --open || true

[group('rust'), no-cd]
build:
    #!/usr/bin/env bash
    set -e
    echo "Running build in bevy-xp"
    cd yard-rs/bevy-xp && cargo build
    cd ../..
    echo "Running build in candle-xp"
    cd yard-rs/candle-xp && cargo build
    cd ../..
    echo "Running build in clifford-xp"
    cd yard-rs/clifford-xp && cargo build
    cd ../..
    echo "Running build in lists"
    cd yard-rs/lists && cargo build
    cd ../..
    echo "Running build in rust_cpp"
    cd yard-rs/rust_cpp && cargo build
    cd ../..
    echo "Running build in cubecl-xp"
    cd yard-rs/cubecl-xp && cargo build
    cd ../..
    echo "Running build in tch-xp"
    cd yard-rs/tch-xp && cargo build
    cd ../..
    echo "Running build in dx-xp"
    cd yard-rs/dx-xp && cargo build
    cd ../..
    echo "Running build in rust_basics"
    cd yard-rs/rust_basics && cargo build
    cd ../..
    echo "Running build in rustry"
    cd yard-rs/rustry && cargo build
    cd ../..

[group('rust'), no-cd]
build-stable:
    #!/usr/bin/env bash
    set -e
    echo "Running +stable build in bevy-xp"
    cd yard-rs/bevy-xp && cargo +stable build
    cd ../..
    echo "Running +stable build in candle-xp"
    cd yard-rs/candle-xp && cargo +stable build
    cd ../..
    echo "Running +stable build in clifford-xp"
    cd yard-rs/clifford-xp && cargo +stable build
    cd ../..
    echo "Running +stable build in lists"
    cd yard-rs/lists && cargo +stable build
    cd ../..
    echo "Running +stable build in rust_cpp"
    cd yard-rs/rust_cpp && cargo +stable build
    cd ../..
    echo "Running +stable build in cubecl-xp"
    cd yard-rs/cubecl-xp && cargo +stable build
    cd ../..
    echo "Running +stable build in tch-xp"
    cd yard-rs/tch-xp && cargo +stable build
    cd ../..
    echo "Running +stable build in dx-xp"
    cd yard-rs/dx-xp && cargo +stable build
    cd ../..
    echo "Running +stable build in rust_basics"
    cd yard-rs/rust_basics && cargo +stable build
    cd ../..
    echo "Running +stable build in rustry"
    cd yard-rs/rustry && cargo +stable build
    cd ../..

[group('rust'), no-cd]
build-nightly:
    #!/usr/bin/env bash
    set -e
    echo "Running +nightly build in bevy-xp"
    cd yard-rs/bevy-xp && cargo +nightly build
    cd ../..
    echo "Running +nightly build in candle-xp"
    cd yard-rs/candle-xp && cargo +nightly build
    cd ../..
    echo "Running +nightly build in clifford-xp"
    cd yard-rs/clifford-xp && cargo +nightly build
    cd ../..
    echo "Running +nightly build in lists"
    cd yard-rs/lists && cargo +nightly build
    cd ../..
    echo "Running +nightly build in rust_cpp"
    cd yard-rs/rust_cpp && cargo +nightly build
    cd ../..
    echo "Running +nightly build in cubecl-xp"
    cd yard-rs/cubecl-xp && cargo +nightly build
    cd ../..
    echo "Running +nightly build in tch-xp"
    cd yard-rs/tch-xp && cargo +nightly build
    cd ../..
    echo "Running +nightly build in dx-xp"
    cd yard-rs/dx-xp && cargo +nightly build
    cd ../..
    echo "Running +nightly build in rust_basics"
    cd yard-rs/rust_basics && cargo +nightly build
    cd ../..
    echo "Running +nightly build in rustry"
    cd yard-rs/rustry && cargo +nightly build
    cd ../..

[group('rust'), no-cd]
run *PARAMS:
    cargo run {{PARAMS}}

# [group('rust'), no-cd]
# nightly: prep-nightly test-nightly

[group('rust'), no-cd]
fmt:
    #!/usr/bin/env bash
    set -e
    echo "Running fmt in bevy-xp"
    cd yard-rs/bevy-xp && cargo fmt
    cd ../..
    echo "Running fmt in candle-xp"
    cd yard-rs/candle-xp && cargo fmt
    cd ../..
    echo "Running fmt in clifford-xp"
    cd yard-rs/clifford-xp && cargo fmt
    cd ../..
    echo "Running fmt in lists"
    cd yard-rs/lists && cargo fmt
    cd ../..
    echo "Running fmt in rust_cpp"
    cd yard-rs/rust_cpp && cargo fmt
    cd ../..
    echo "Running fmt in cubecl-xp"
    cd yard-rs/cubecl-xp && cargo fmt
    cd ../..
    echo "Running fmt in tch-xp"
    cd yard-rs/tch-xp && cargo fmt
    cd ../..
    echo "Running fmt in dx-xp"
    cd yard-rs/dx-xp && cargo fmt
    cd ../..
    echo "Running fmt in rust_basics"
    cd yard-rs/rust_basics && cargo fmt
    cd ../..
    echo "Running fmt in rustry"
    cd yard-rs/rustry && cargo fmt
    cd ../..

[group('util'), no-cd]
kill NAME:
    ps aux|grep {{NAME}}|grep -v grep|grep -v just|awk '{print $2}'|xargs kill -9

[private]
status:
    watchexec --quiet --no-meta --debounce 500ms --project-origin . -w . --emit-events-to=stdio -- git status

[linux]
prep-linux:
    #!/usr/bin/env bash
    apt update
    apt install -y libwebkit2gtk-4.1-dev \
    build-essential \
    pkg-config \
    curl \
    wget \
    file \
    unzip \
    libxdo-dev \
    libssl-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    libx11-dev libasound2-dev libudev-dev libxkbcommon-x11-0 \
    libgtk-3-dev libglib2.0-dev


[unix, private]
@prep-binstall-unix:
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash 

[linux, private]
@prep-binstall:
    which cargo-binstall || (just prep-binstall-unix)

[macos, private]
@prep-binstall:
    which cargo-binstall || (just prep-binstall-unix) || brew install cargo-binstall

[windows, private]
@prep-binstall:
    which cargo-binstall || cargo install cargo-binstall

[group('rust'), no-cd]
@prep-test: prep-binstall
    which cargo-nextest || (yes|cargo binstall cargo-nextest --secure)
    which cargo-llvm-cov || (yes|cargo binstall cargo-llvm-cov --secure)
    which cargo-deny || (yes|cargo binstall cargo-deny --secure)

# clone-ex:
#     #!/usr/bin/env bash
#     if [[ ! -d archived/exercism ]]; then git clone https://github.com/utensil/exercism archived/exercism; fi

# can't fight with the workspace not exluded error
# test-ex: clone-ex
#     cd archived/exercism && git pull && ./verify_rs.sh


# [group('python')]
# [macos]
# prep-mm:
#     brew install micromamba

# by default this is installed to $HOME/.local/bin
# so mamba can be always called with $HOME/.local/bin/micromamba
# the default MAMBA_ROOT_PREFIX is $HOME/micromamba 

# [group('tch')]
# prep-mm:
#     #!/usr/bin/env bash
#     curl -L --proto '=https' --tlsv1.2 -sSf https://micro.mamba.pm/install.sh | bash
#     $HOME/.local/bin/micromamba --version

LIBTORCH_FILENAME := if os() == "windows" {
    "libtorch-win-shared-with-deps-2.4.0%2Bcpu.zip"
} else if os() == "linux" {
    "libtorch-cxx11-abi-shared-with-deps-2.4.0%2Bcpu.zip"
} else if os() == "macos" {
    if arch() == "aarch64" {
        "libtorch-macos-arm64-2.4.0.zip"
    } else {
        "libtorch-macos-x86_64-2.4.0.zip"
    }
} else {
    ""
}

LIBTORCH_ZIP_PATH := clean(join(LIBTORCH_PREFIX, LIBTORCH_FILENAME))
LIBTORCH_DIR := clean(join(LIBTORCH_PREFIX, "libtorch"))

[group('tch')]
prep-tch:
    #!/usr/bin/env bash
    # $HOME/.local/bin/micromamba env create -y -f yard-rs/tch-xp/environment.yml
    if [[ ! -f {{ LIBTORCH_PREFIX / LIBTORCH_FILENAME }} ]]; then
        curl {{ "https://download.pytorch.org/libtorch/cpu" / LIBTORCH_FILENAME }} -o "{{ LIBTORCH_ZIP_PATH }}"
    fi
    echo "Downloaded to {{ LIBTORCH_ZIP_PATH }}"
    if [[ ! -d {{ LIBTORCH_DIR }} ]]; then
        unzip -o "{{ LIBTORCH_ZIP_PATH }}" -d "{{ LIBTORCH_PREFIX }}" 2>&1 > /dev/null
    fi
    echo "Unzipped to {{ LIBTORCH_DIR }}"

[group('rust-gpu')]
test-rsgpu:
    cd yard-rs/rsgpu-xp && just test

[group('rust-gpu')]
cov-rsgpu:
    cd yard-rs/rsgpu-xp && just cov

prep-cache: prep-binstall
    which sccache || (yes|cargo binstall sccache)

[unix]
prep-uv:
    curl -LsSf https://astral.sh/uv/install.sh | sh

[windows]
prep-uv:
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

add-zrc LINE:
    grep -F '{{LINE}}' ~/.zshrc|| echo '{{LINE}}' >> ~/.zshrc

prep-llvm:
    brew install llvm@19

prep-llvm18:
    brew install llvm@18
    just add-zrc 'export LDFLAGS="-L/opt/homebrew/opt/llvm@18/lib/c++ -L/opt/homebrew/opt/llvm@18/lib -lunwind"'
    just add-zrc 'export PATH="/opt/homebrew/opt/llvm@18/bin:$PATH"' 
    just add-zrc 'export LDFLAGS="-L/opt/homebrew/opt/llvm@18/lib"'
    just add-zrc 'export CPPFLAGS="-I/opt/homebrew/opt/llvm@18/include"'

prep-llvm17:
    brew install llvm@17

prep-gcc:
    brew install gcc@13

prep-rust:
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly
    just add-zrc '. $HOME/.cargo/env'

# Auto-discovery tasks for all rust projects
[group('rust'), no-cd]
test-all:
    #!/usr/bin/env bash
    set -e
    for dir in $(find yard-rs -maxdepth 1 -type d -exec test -f {}/Cargo.toml \; -print | sed 's|yard-rs/||' | sort); do
        echo "Running nextest run --no-fail-fast --retries 2 in $dir"
        cd yard-rs/$dir && cargo nextest run --no-fail-fast --retries 2
        cd ../..
    done

[group('rust'), no-cd] 
test-stable-all:
    #!/usr/bin/env bash
    set -e
    for dir in $(find yard-rs -maxdepth 1 -type d -exec test -f {}/Cargo.toml \; -print | sed 's|yard-rs/||' | sort); do
        echo "Running +stable nextest run --no-fail-fast --retries 2 in $dir"
        cd yard-rs/$dir && cargo +stable nextest run --no-fail-fast --retries 2
        cd ../..
    done

[group('rust'), no-cd]
@test-nightly-all:
    #!/usr/bin/env bash
    set -e
    for dir in $(find yard-rs -maxdepth 1 -type d -exec test -f {}/Cargo.toml \; -print | sed 's|yard-rs/||' | sort); do
        echo "Running +nightly nextest run --no-fail-fast --retries 2 in $dir"
        cd yard-rs/$dir && yes|cargo +nightly nextest run --no-fail-fast --retries 2
        cd ../..
    done

[group('rust'), no-cd]
build-all:
    #!/usr/bin/env bash
    set -e
    for dir in $(find yard-rs -maxdepth 1 -type d -exec test -f {}/Cargo.toml \; -print | sed 's|yard-rs/||' | sort); do
        echo "Running build in $dir"
        cd yard-rs/$dir && cargo build
        cd ../..
    done

[group('rust'), no-cd]
build-stable-all:
    #!/usr/bin/env bash
    set -e
    for dir in $(find yard-rs -maxdepth 1 -type d -exec test -f {}/Cargo.toml \; -print | sed 's|yard-rs/||' | sort); do
        echo "Running +stable build in $dir"
        cd yard-rs/$dir && cargo +stable build
        cd ../..
    done

[group('rust'), no-cd]
build-nightly-all:
    #!/usr/bin/env bash
    set -e
    for dir in $(find yard-rs -maxdepth 1 -type d -exec test -f {}/Cargo.toml \; -print | sed 's|yard-rs/||' | sort); do
        echo "Running +nightly build in $dir"
        cd yard-rs/$dir && cargo +nightly build
        cd ../..
    done

[group('rust'), no-cd]
fmt-all:
    #!/usr/bin/env bash
    set -e
    for dir in $(find yard-rs -maxdepth 1 -type d -exec test -f {}/Cargo.toml \; -print | sed 's|yard-rs/||' | sort); do
        echo "Running fmt in $dir"
        cd yard-rs/$dir && cargo fmt
        cd ../..
    done

[group('rust'), no-cd]
clippy-all:
    #!/usr/bin/env bash
    set -e
    for dir in $(find yard-rs -maxdepth 1 -type d -exec test -f {}/Cargo.toml \; -print | sed 's|yard-rs/||' | sort); do
        echo "Running clippy in $dir"
        cd yard-rs/$dir && cargo clippy --all-targets --all-features -- -D warnings
        cd ../..
    done

[group('rust'), no-cd]
clippy-stable-all:
    #!/usr/bin/env bash
    set -e
    for dir in $(find yard-rs -maxdepth 1 -type d -exec test -f {}/Cargo.toml \; -print | sed 's|yard-rs/||' | sort); do
        echo "Running +stable clippy in $dir"
        cd yard-rs/$dir && cargo +stable clippy --all-targets --all-features -- -D warnings
        cd ../..
    done

[group('rust'), no-cd]
clippy-nightly-all:
    #!/usr/bin/env bash
    set -e
    for dir in $(find yard-rs -maxdepth 1 -type d -exec test -f {}/Cargo.toml \; -print | sed 's|yard-rs/||' | sort); do
        echo "Running +nightly clippy in $dir"
        cd yard-rs/$dir && cargo +nightly clippy --all-targets --all-features -- -D warnings
        cd ../..
    done

[group('rust'), no-cd]
cov-all:
    #!/usr/bin/env bash
    set -e
    rm -f lcov.info
    for dir in $(find yard-rs -maxdepth 1 -type d -exec test -f {}/Cargo.toml \; -print | sed 's|yard-rs/||' | sort); do
        echo "Running llvm-cov --branch --lcov --output-path lcov-$dir.info nextest --no-fail-fast --retries 2 in $dir"
        cd yard-rs/$dir && yes|cargo llvm-cov --branch --lcov --output-path ../../lcov-$dir.info nextest --no-fail-fast --retries 2 || true
        cd ../..
    done
    lcov $(find . -name "lcov-*.info" | sed 's/^/--add-tracefile /') --output-file lcov.info || true

[group('rust'), no-cd]
cov-nightly-all:
    #!/usr/bin/env bash
    set -e
    rm -f lcov.info
    for dir in $(find yard-rs -maxdepth 1 -type d -exec test -f {}/Cargo.toml \; -print | sed 's|yard-rs/||' | sort); do
        echo "Running +nightly llvm-cov --branch --lcov --output-path lcov-$dir.info nextest --no-fail-fast --retries 2 in $dir"
        cd yard-rs/$dir && yes|cargo +nightly llvm-cov --branch --lcov --output-path ../../lcov-$dir.info nextest --no-fail-fast --retries 2 || true
        cd ../..
    done
    lcov $(find . -name "lcov-*.info" | sed 's/^/--add-tracefile /') --output-file lcov.info || true

[group('rust'), no-cd]
run-all PROJECT *PARAMS:
    #!/usr/bin/env bash
    set -e
    if [ -d "yard-rs/{{PROJECT}}" ] && [ -f "yard-rs/{{PROJECT}}/Cargo.toml" ]; then
        echo "Running cargo run {{PARAMS}} in {{PROJECT}}"
        cd yard-rs/{{PROJECT}} && cargo run {{PARAMS}}
    else
        echo "Error: Project '{{PROJECT}}' not found in yard-rs/ or is not a valid Rust project"
        echo "Available projects:"
        find yard-rs -maxdepth 1 -type d -exec test -f {}/Cargo.toml \; -print | sed 's|yard-rs/||' | sort
        exit 1
    fi

