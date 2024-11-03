# to install just:
# run: curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

export HOMEBREW_NO_AUTO_UPDATE := "1"
export BINSTALL_DISABLE_TELEMETRY := "true"
export RUST_BACKTRACE :="1"
export RUSTC_WRAPPER := "sccache"
# export CARGO_BUILD_JOBS := "4"

# export MAMBA_ROOT_PREFIX := clean(join(justfile_directory(), "..", "micromamba"))
# mm_packages := join(MAMBA_ROOT_PREFIX, "envs", "tch-rs", "lib", "python3.11", "site-packages")
# export LIBTORCH := join(mm_packages , "torch")

LIBTORCH_PREFIX := clean(join(justfile_directory() , ".."))
export LIBTORCH := join(LIBTORCH_PREFIX, "libtorch")
env_sep := if os() == "windows" { ";" } else { ":" }
export PATH := join(LIBTORCH, "lib") + env_sep + env_var("PATH")

default:
    just list

# this could be used to do quick ad hoc checks in CI with little installed
check:
    just
    echo "LIBTORCH=$LIBTORCH"
    echo "PATH=$PATH"

prep-ci:
    just prep-cache
    just prep-tch

[linux]
ci: prep-ci
    just clippy
    just cov
    # just cov-rsgpu

[macos]
[windows]
ci: prep-ci
    just clippy
    just test
    # just test-rsgpu

[group('rust'), no-cd]
test:
    cargo nextest run --no-fail-fast --retries 2

[group('util'), no-cd]
list:
    just --list

[group('rust'), no-cd]
test-stable:
    cargo +stable nextest run --no-fail-fast --retries 2

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
    # cargo +nightly build --all-targets --keep-going
    # cargo +nightly test --all-targets --no-fail-fast
    yes|cargo +nightly nextest run --no-fail-fast --retries 2

[group('rust'), no-cd]
cov:
    yes|cargo llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2

[group('rust'), no-cd]
cov-nightly:
    yes|cargo +nightly llvm-cov --branch --lcov --output-path lcov.info nextest --no-fail-fast --retries 2

[group('rust'), no-cd]
clippy:
    cargo clippy

[group('rust'), no-cd]
clippy-stable:
    cargo +stable clippy

[group('rust'), no-cd]
clippy-nightly:
    cargo +nightly clippy

vcov: cov
    cargo llvm-cov report --ignore-filename-regex main.rs --html --open

[group('rust'), no-cd]
build:
    cargo build

[group('rust'), no-cd]
build-stable:
    cargo +stable build

[group('rust'), no-cd]
build-nightly:
    cargo +nightly build

# [group('rust'), no-cd]
# nightly: prep-nightly test-nightly

[group('rust'), no-cd]
fmt:
    cargo fmt

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

[group('tch')]
prep-tch:
    cd yard-rs/tch-xp && just prep-tch

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

add-rc LINE:
    grep -F '{{LINE}}' ~/.zshrc|| echo '{{LINE}}' >> ~/.zshrc

prep-llvm:
    brew install llvm@18
    just add-rc 'export LDFLAGS="-L/opt/homebrew/opt/llvm@18/lib/c++ -L/opt/homebrew/opt/llvm@18/lib -lunwind"'
    just add-rc 'export PATH="/opt/homebrew/opt/llvm@18/bin:$PATH"' 
    just add-rc 'export LDFLAGS="-L/opt/homebrew/opt/llvm@18/lib"'
    just add-rc 'export CPPFLAGS="-I/opt/homebrew/opt/llvm@18/include"'

prep-gcc:
    brew install gcc@13
