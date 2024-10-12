# to install just:
# run: curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

default:
    just test-nightly

test:
    cargo test --workspace --features=wgpu

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

format:
    cargo fmt

kill NAME:
    ps aux|grep {{NAME}}|grep -v grep|grep -v just|awk '{print $2}'|xargs kill -9

status:
    watchexec --quiet --no-meta --debounce 500ms --project-origin . -w . --emit-events-to=stdio -- git status

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


# clone-ex:
#     #!/usr/bin/env bash
#     if [[ ! -d archived/exercism ]]; then git clone https://github.com/utensil/exercism archived/exercism; fi

# can't fight with the workspace not exluded error
# test-ex: clone-ex
#     cd archived/exercism && git pull && ./verify_rs.sh
