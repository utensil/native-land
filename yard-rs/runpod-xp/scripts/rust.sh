#!/bin/bash

# set -euxo pipefail

# set -x

WORKSPACE=${WORKSPACE:-"/workspace"}

export DEBIAN_FRONTEND=noninteractive

# make the cache live on volume disk
rm -rf /root/.cache
mkdir -p /content/cache
ln -s /content/cache /root/.cache

cd "$WORKSPACE" 

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

LOGFILE=/content/rust.log

echo "Redirecting output to $LOGFILE"
echo "To inspect, run: tail -f $LOGFILE"

exec >> $LOGFILE 2>&1

cd native-land
just prep-linux
# cd yard-rs/bevy-xp
# cargo test
# cd ../../
# cd yard-rs/cubecl-xp
# cargo test --no-default-features --features=cuda
# cargo run --example gelu --no-default-features --features=cuda
# cd ../../
# cd yard-rs/krnl-xp
# cargo test
# cd ../../
just ci || echo "❌ CI failed"

cd /content/native-land/yard-rs/runpod-xp
time just prep-uv
sleep 60
time just kill

sleep infinity
