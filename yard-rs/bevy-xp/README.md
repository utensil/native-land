Should also check out:

- https://bevy-cheatbook.github.io/introduction.html
- https://thisweekinbevy.com/

- https://github.com/bevyengine/bevy/blob/main/examples/async_tasks/async_compute.rs
- https://github.com/AnthonyTornetta/bevy_easy_compute
- https://github.com/Stranget0/wanderer-tales
- https://github.com/eliotbo/bevy_shadertoy_wgsl
- https://github.com/narasan49/bevy-fluid-sample

- https://github.com/IyesGames/iyes_perf_ui
- https://github.com/NiklasEi/bevy_asset_loader

- https://github.com/iiYese/aery
- https://github.com/nannou-org/nannou
- https://github.com/bevyengine/bevy_github_ci_template
- https://github.com/NiklasEi/bevy_game_template

For rust-gpu, should check out:

- https://embarkstudios.github.io/rust-gpu/book/writing-shader-crates.html
- used extensively by
  - https://github.com/charles-r-earp/autograph
    - https://github.com/charles-r-earp/krnl
  - https://github.com/schell/renderling
  - https://github.com/GraphiteEditor/Graphite
- Bevy-Rust-GPU Compute example: https://github.com/Bevy-Rust-GPU/example-workspace/pull/22
- documentation and examples for porting WGSL/GLSL shaders: https://github.com/EmbarkStudios/rust-gpu/issues/1096
  - https://github.com/bevyengine/bevy/blob/main/assets/shaders/game_of_life.wgsl
  - https://github.com/Bevy-Rust-GPU/example-workspace/pull/22#issuecomment-1796063937
- Infrastructure for using ShaderToy as a test corpus https://github.com/EmbarkStudios/rust-gpu/issues/1104
  - Add some more example shaders : https://github.com/EmbarkStudios/rust-gpu/pull/1146
- https://github.com/EmbarkStudios/rust-gpu/issues?q=
- https://github.com/mitchmindtree/nannou-rustgpu-raytracer

For CubeCL, should check out:

- [CubeCL Architecture Overview - Running Rust on your GPU (WebGPU, CUDA)](https://gist.github.com/nihalpasham/570d4fe01b403985e1eaf620b6613774)
- https://github.com/nobuyuki83/floor_plan
- CubeCL is most extensively used in its [JIT backend](https://github.com/tracel-ai/burn/tree/main/crates/burn-jit)

For candle, should check out:

- https://github.com/ToluClassics/candle-tutorial
- https://github.com/tomsanbear/candle-einops
- Burn has a [candle backend](https://github.com/tracel-ai/burn/tree/main/crates/burn-candle)

For tch-rs, should check out:

- https://github.com/zurgl/makemore-rs
- https://github.com/VasanthakumarV/einops
- Burn has a [tch backend](https://github.com/tracel-ai/burn/tree/main/crates/burn-tch)

For wgpu, don't forget to check out:

- https://github.com/Kiiyya/lean-wgpu

For benchmarking and profiling, should check out:

- https://nnethercote.github.io/perf-book/benchmarking.html
- https://nnethercote.github.io/perf-book/profiling.html
  - https://github.com/flamegraph-rs/flamegraph
  - https://github.com/mstange/samply/
- https://github.com/wolfpld/tracy (seems to be the best, wide CPU/GPU support)
  - https://github.com/nagisa/rust_tracy_client
    - https://github.com/Wumpf/wgpu-profiler/pull/35
      - [doesn't support GPU profiling for Metal](https://github.com/Wumpf/wgpu-profiler/blob/920b845e3a9d5c86310b5bc0ea3d56dbb45eaeda/src/tracy.rs#L44)
  - https://github.com/tokio-rs/loom
- https://github.com/Celtoys/Remotery
- https://github.com/bevyengine/bevy/blob/main/docs/profiling.md (most informative on profiling)
- https://github.com/mikesart/gpuvis

An interesting task: convert GPU puzzles into Rust
  - https://github.com/srush/GPU-Puzzles
  - https://github.com/AnswerDotAI/gpu.cpp/tree/main/examples/gpu_puzzles
  - https://github.com/abeleinin/Metal-Puzzles