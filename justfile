# to install just:
# run: curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

default:
    just test-nightly

list:
    just --list

test-stable:
    cargo +stable test --features=wgpu

build-stable:
    cargo +stable build

prep-stable:
    # https://rust-analyzer.github.io/manual.html#installation
    rustup toolchain install stable
    rustup component add rust-src
    rustup component add rust-analyzer

prep-nightly:
    rustup toolchain install nightly
    rustup component add rust-src --toolchain nightly
    rustup component add rust-analyzer --toolchain nightly

test-nightly:
    cargo +nightly build --features=wgpu --all-targets --keep-going
    cargo +nightly test --features=wgpu --all-targets --no-fail-fast

build-nightly:
    cargo +nightly build

nightly: prep-nightly test-nightly

fmt:
    cargo fmt

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

# prep-test:
#     cargo install cargo-nextest

# Install binstall, nextest
[linux]
prep-test:
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
    cargo binstall nextest

# Install binstall, nextest
[macos]
prep-test:
    brew install cargo-binstall
    yes|cargo binstall nextest

# clone-ex:
#     #!/usr/bin/env bash
#     if [[ ! -d archived/exercism ]]; then git clone https://github.com/utensil/exercism archived/exercism; fi

# can't fight with the workspace not exluded error
# test-ex: clone-ex
#     cd archived/exercism && git pull && ./verify_rs.sh
