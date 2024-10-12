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

mkdir -p /content/
cd /content/

if [ ! -d "native-land" ]; then
  git clone https://github.com/utensil/native-land
# don't update between run yet
# else
#   (cd native-land && git pull)
fi

cd native-land
just prep-linux
cd yard-rs/bevy-xp
cargo test
cd ../../
cd yard-rs/cubecl-xp
cargo test

pip install runpod
cd /content/native-land/yard-rs/runpod-xp
just kill

sleep infinity