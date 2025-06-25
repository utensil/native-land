# to install just:
# run: curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin
set unstable

export HOMEBREW_NO_AUTO_UPDATE := "1"
export BINSTALL_DISABLE_TELEMETRY := "true"
export RUST_BACKTRACE :="1"

# https://github.com/mozilla/sccache?tab=readme-ov-file#usage
# By default, sccache will fail your build if it fails to successfully communicate with its associated server. To have sccache instead gracefully failover to the local compiler without stopping
export SCCACHE_IGNORE_SERVER_IO_ERROR := "1"
# Running sccache is like running ccache: prefix your compilation commands with it
# Alternatively you can use the environment variable RUSTC_WRAPPER:
export RUSTC_WRAPPER := which("sccache")
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

ci: prep-ci
    #!/usr/bin/env bash
    export RUSTC_WRAPPER=`which sccache`
    echo "Using RUSTC_WRAPPER=$RUSTC_WRAPPER"
    ROOT_DIR=$(pwd)
    FAILED_PROJECTS=()
    PASSED_PROJECTS=()
    NO_TESTS_PROJECTS=()
    CLIPPY_FAILED_PROJECTS=()
    ALL_OUTPUT=""
    
    # Color codes
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    GRAY='\033[0;90m'
    YELLOW='\033[0;33m'
    NC='\033[0m' # No Color
    
    # Determine test command based on OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        TEST_COMMAND="cov"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        TEST_COMMAND="cov"
    else
        TEST_COMMAND="test"
        export WGPU_BACKEND=dx12
        export BEVY_CI_FORCE_WINIT_BACKEND=windows
    fi
    TEST_OUTPUT_HEADER="just $TEST_COMMAND OUTPUT"
    
    for project in yard-rs/bevy-xp yard-rs/candle-xp yard-rs/clifford-xp yard-rs/cubecl-xp yard-rs/dx-xp yard-rs/lists yard-rs/rust_basics yard-rs/rust_cpp yard-rs/rustry yard-rs/tch-xp; do
        echo -e "${BLUE}Running CI for $project...${NC}"
        cd "$ROOT_DIR/$project"
        
        # Run clippy and capture output
        CLIPPY_OUTPUT=$(just clippy 2>&1)
        CLIPPY_EXIT_CODE=$?
        
        if [ $CLIPPY_EXIT_CODE -ne 0 ]; then
            echo -e "${RED}Clippy failed for $project${NC}"
            ALL_OUTPUT+="\n=== CLIPPY OUTPUT for $project ===\n"
            ALL_OUTPUT+="$CLIPPY_OUTPUT\n"
            CLIPPY_FAILED_PROJECTS+=("$project")
            FAILED_PROJECTS+=("$project")
            continue
        fi
        
        # Run test/cov and capture output with colors preserved
        TEST_OUTPUT=$(script -q /dev/null just $TEST_COMMAND 2>&1)
        TEST_EXIT_CODE=$?
        
        if [ $TEST_EXIT_CODE -eq 0 ]; then
            echo -e "${GREEN}Tests passed for $project${NC}"
            ALL_OUTPUT+="\n=== CLIPPY OUTPUT for $project ===\n"
            ALL_OUTPUT+="$CLIPPY_OUTPUT\n"
            ALL_OUTPUT+="\n=== $TEST_OUTPUT_HEADER for $project ===\n"
            ALL_OUTPUT+="$TEST_OUTPUT\n"
            PASSED_PROJECTS+=("$project")
        elif echo "$TEST_OUTPUT" | grep -q "no tests to run"; then
            echo -e "${GRAY}No tests found for $project${NC}"
            NO_TESTS_PROJECTS+=("$project")
        else
            echo -e "${RED}Tests failed for $project${NC}"
            ALL_OUTPUT+="\n=== CLIPPY OUTPUT for $project ===\n"
            ALL_OUTPUT+="$CLIPPY_OUTPUT\n"
            ALL_OUTPUT+="\n=== $TEST_OUTPUT_HEADER for $project ===\n"
            ALL_OUTPUT+="$TEST_OUTPUT\n"
            FAILED_PROJECTS+=("$project")
        fi
    done
    
    # Print all captured output (only for projects with tests)
    echo -e "$ALL_OUTPUT"
    
    # Print summary with colors
    echo ""
    echo "=== CI SUMMARY ==="
    echo -e "${GREEN}PASSED: ${#PASSED_PROJECTS[@]} projects${NC}"
    for project in "${PASSED_PROJECTS[@]}"; do
        echo -e "  ${GREEN}✓${NC} $project"
    done
    
    echo -e "${GRAY}NO TESTS: ${#NO_TESTS_PROJECTS[@]} projects${NC}"
    for project in "${NO_TESTS_PROJECTS[@]}"; do
        echo -e "  ${GRAY}-${NC} $project"
    done
    
    if [ ${#CLIPPY_FAILED_PROJECTS[@]} -gt 0 ]; then
        echo -e "${YELLOW}CLIPPY FAILED: ${#CLIPPY_FAILED_PROJECTS[@]} projects${NC}"
        for project in "${CLIPPY_FAILED_PROJECTS[@]}"; do
            echo -e "  ${YELLOW}⚠${NC} $project"
        done
    fi
    
    if [ ${#FAILED_PROJECTS[@]} -gt 0 ]; then
        echo -e "${RED}TOTAL FAILED: ${#FAILED_PROJECTS[@]} projects${NC}"
        for project in "${FAILED_PROJECTS[@]}"; do
            echo -e "  ${RED}✗${NC} $project"
        done
    else
        echo -e "${BLUE}TOTAL FAILED: ${#FAILED_PROJECTS[@]} projects${NC}"
    fi
    
    # Exit with failure if any projects actually failed (clippy or tests)
    if [ ${#FAILED_PROJECTS[@]} -gt 0 ]; then
        exit 1
    fi
    
    # cd yard-rs/krnl-xp && just test
    # just cov-rsgpu



[group('util'), no-cd]
list:
    just --list



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























# [group('rust'), no-cd]
# nightly: prep-nightly test-nightly



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

cache:
    sccache --show-stats

cache-reset:
    sccache --zero-stats
    sccache --stop-server
    sccache --start-server

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

clean:
    #!/usr/bin/env bash
    while IFS= read -r project; do
        echo "Cleaning $project..."
        cd "$project"
        cargo clean
        rm -f Cargo.lock
        cd -
    done < <(find yard-rs -name "Cargo.toml" -exec dirname {} \;)



