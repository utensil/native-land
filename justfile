# to install just:
# run: curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

export HOMEBREW_NO_AUTO_UPDATE := "1"

default:
    just --list

[group('shared'), no-cd]
test:
    just test-nightly

[group('shared'), no-cd]
list:
    just --list

[group('shared'), no-cd]
test-stable:
    cargo +stable test

[group('shared'), no-cd]
build-stable:
    cargo +stable build

[group('shared'), no-cd]
prep-stable:
    # https://rust-analyzer.github.io/manual.html#installation
    rustup toolchain install stable
    rustup component add rust-src
    rustup component add rust-analyzer

[group('shared'), no-cd]
prep-nightly:
    rustup toolchain install nightly
    rustup component add rust-src --toolchain nightly
    rustup component add rust-analyzer --toolchain nightly

[group('shared'), no-cd]
@test-nightly:
    # cargo +nightly build --all-targets --keep-going
    # cargo +nightly test --all-targets --no-fail-fast
    yes|cargo +nightly nextest run --all-targets --no-fail-fast --retries 2

[group('shared'), no-cd]
cov: cov-nightly

[group('shared'), no-cd]
cov-nightly:
    yes|cargo +nightly llvm-cov nextest --all-targets --no-fail-fast --retries 2

[group('shared'), no-cd]
build-nightly:
    cargo +nightly build

[group('shared'), no-cd]
nightly: prep-nightly test-nightly

[group('shared'), no-cd]
fmt:
    cargo fmt

[group('shared'), no-cd]
kill NAME:
    ps aux|grep {{NAME}}|grep -v grep|grep -v just|awk '{print $2}'|xargs kill -9

_status:
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
    libxdo-dev \
    libssl-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    libx11-dev libasound2-dev libudev-dev libxkbcommon-x11-0 \
    libgtk-3-dev libglib2.0-dev


[unix]
@prep-binstall-unix:
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash 

[macos]
@prep-binstall:
    which cargo-binstall || (just prep-binstall-unix) || brew install cargo-binstall

[windows]
@prep-binstall:
    cargo install cargo-binstall

[group('shared'), no-cd]
@prep-test: prep-binstall
    which cargo-nextest || (yes|cargo binstall cargo-nextest --secure)
    which cargo-llvm-cov || (yes|cargo binstall cargo-llvm-cov --secure)

# clone-ex:
#     #!/usr/bin/env bash
#     if [[ ! -d archived/exercism ]]; then git clone https://github.com/utensil/exercism archived/exercism; fi

# can't fight with the workspace not exluded error
# test-ex: clone-ex
#     cd archived/exercism && git pull && ./verify_rs.sh
