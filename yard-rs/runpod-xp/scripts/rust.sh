#!/bin/bash

set -euxo pipefail

set -x

WORKSPACE=${WORKSPACE:-"/workspace"}

export DEBIAN_FRONTEND=noninteractive

# make the cache live on volume disk
rm -rf /root/.cache
mkdir -p /content/cache
ln -s /content/cache /root/.cache

cd $WORKSPACE

curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin || which just
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly -y
. "$HOME/.cargo/env"

mkdir -p /content/
cd /content/

if [ ! -d "native-land" ]; then
  git clone https://github.com/utensil/native-land
else
  (cd native-land && git pull)
fi

cd native-land
just prep-linux
cd yard-rs/bevy-xp
cargo test
cd ../../
cd yard-rs/cubecl-xp
cargo test --no-default-features --features=cuda
cargo run --example gelu --no-default-features --features=cuda

cd /content/native-land/yard-rs/runpod-xp
pip install -r requirements-runpod.txt
just kill

sleep infinity