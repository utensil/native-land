It's almost ten year now since I learn about Geometric Algebra.

After my work on GAlgebra, GAlgebra.jl, lean-ga, I have been interested in working on GA in Rust.

My survey of related projects can be found in my Github stars in topic [ga.rs](https://github.com/stars/utensil/lists/ga-rs).

Now the unified idea is to build a Rust library, with generic metric in mind (including high dimensions, degenerate metrics, and other non-Euclidean geometries), with GC in mind, with a friendly DSL and an expressive API, with numeric, symbolic, and formal backends, in both CPU and GPU land when applicable, with LaTeX, code generation and 3D visualization as output, with benchmark setup for comparison between backends, and with prior art.

I'll do this buried deeply in my native-land monorepo, until it becomes mature enough to be a standalone project.

API and basic abstraction can be just like [kingdon](https://github.com/tBuLi/kingdon) which models after [GAmphetamine.js](https://enki.ws/GAM/src/GAmphetamine.js), which is still not released.

Making all dependencies optional like [glam](https://github.com/bitshifter/glam-rs?tab=readme-ov-file#design-philosophy) is tempting and challenging.

To have a DSL in it, my favorite is [rhai](https://github.com/rhaiscript/rhai).

Numeric backends can be based on (not updated in 2 years are marked with the last update year)

- Rust
  - [glam](https://github.com/bitshifter/glam-rs)
  - [nalgebra](https://github.com/dimforge/nalgebra)
  - [ultraviolet](https://github.com/fu5ha/ultraviolet)
  - [Lichtso/geometric_algebra](https://github.com/Lichtso/geometric_algebra)
  - [wrnrlr/g3](https://github.com/wrnrlr/g3)
  - [AminMoazzen/cliffy](https://github.com/AminMoazzen/cliffy) (2022)
  - [jsmith628/wedged](https://github.com/jsmith628/wedged) (2022)
  - [rustgd/cgmath](https://github.com/rustgd/cgmath) (2022)
- C++
  - [wolftype/versor](https://github.com/wolftype/versor)
  - [gafro](https://github.com/idiap/gafro)
  - [sudgy/sga](https://github.com/sudgy/sga)
  - [gal](https://github.com/jeremyong/gal) (2019)
  - [gatl](https://github.com/laffernandes/gatl) (2022)
  - [diwalkerdev/GeometricAlgebra](https://github.com/diwalkerdev/GeometricAlgebra) (2022)
  - [TbGAL](https://github.com/Prograf-UFF/TbGAL) (2022)
  - [godefv/math](https://github.com/godefv/math) (2020)
  - auto-diff
    - [stan-dev/math](https://github.com/stan-dev/math)
    - [Dr.Jit](https://github.com/mitsuba-renderer/drjit)
    - [Aδ](https://github.com/yyuting/Adelta)
    - [glsl-autodiff](https://github.com/sibaku/glsl-autodiff) in GLSL

There are Zig/Julia backends to consider too, but I'll skip them for now, they are in the `ga.rs` star list.

And for PGA, there could also be

- [emilk/pga](https://github.com/emilk/pga)
- [jamen/klein-rs](https://github.com/jamen/klein-rs)
  - binding to [jeremyong/klein](https://github.com/jeremyong/klein) in C++
- [Terathon-Math-Library](https://github.com/EricLengyel/Terathon-Math-Library)

For GPU backends, there are:

- [wgpu](https://github.com/gfx-rs/wgpu)
- rust-gpu ([original](https://github.com/EmbarkStudios/rust-gpu)) ([new](https://github.com/Rust-GPU/rust-gpu))
- [CubeCL](https://github.com/tracel-ai/cubecl)
  - used by [Burn](https://github.com/tracel-ai/burn)
- [bevy_easy_compute](https://github.com/AnthonyTornetta/bevy_easy_compute)
- [candle](ttps://github.com/huggingface/candle)
  - [candle-einops](https://github.com/tomsanbear/candle-einops)
  - used by [mistral.rs](https://github.com/EricLBuehler/mistral.rs)
- [tch-rs](https://github.com/LaurentMazare/tch-rs)
- [mlx-rs](https://github.com/oxideai/mlx-rs)
- [rai](https://github.com/cksac/rai) JAX-like
- [krnl](https://github.com/charles-r-earp/krnl)
- [luminal](https://github.com/jafioti/luminal) which uses composable compilers and uses egg
- [cudarc](https://github.com/coreylowman/cudarc) for CUDA
- [Ash](https://github.com/ash-rs/ash) for Vulkan
- [gpu.cpp](https://github.com/AnswerDotAI/gpu.cpp) in C++
- [uwal](https://github.com/UstymUkhman/uwal) in JS

Check out [bevy-xp README](../bevy-xp/README.md) for more on GPU backends. See also star list [llm.rs](https://github.com/stars/utensil/lists/llm-rs) and [ad.gpu](https://github.com/stars/utensil/lists/ad-gpu).

For benchmark, there are:

- [bitshifter/mathbench-rs](https://github.com/bitshifter/mathbench-rs) for Rust and math
- [ga-benchmark](https://github.com/loewt/ga-benchmark) for C++ and GA
  - see [paper gafro: Geometric Algebra for Robotics](https://arxiv.org/abs/2310.19090) for plots of results
- [gafro_benchmarks](https://gitlab.com/gafro/gafro_benchmarks) for C++ and robotics
- [gradbench](https://github.com/gradbench/gradbench) for auto-diff
- [metal-benchmarks](https://github.com/philipturner/metal-benchmarks)
- [wgpu-mm](https://github.com/FL33TW00D/wgpu-mm)

I think I'll also use [criterion.rs](https://github.com/bheisler/criterion.rs).

For symbolic backends, there are:

- Rust
  - [cas-rs](https://github.com/ElectrifyPro/cas-rs)
  - [symbolica](https://github.com/benruijl/symbolica) (requires a free license for hobbyist)
  - [podo-os/symengine.rs](https://github.com/podo-os/symengine.rs) 2020
- C++
  - [symengine](https://github.com/symengine/symengine)
  - [GiNaC](https://www.ginac.de/)
  - [cadabra2](https://github.com/kpeeters/cadabra2)

For program optimization, the approach of [mirage](https://github.com/mirage-project/mirage), [StructTensor](https://github.com/edin-dal/structtensor), and `STOREL`(*Optimizing Tensor Programs on Flexible Storage*) based on [SDQL](https://github.com/edin-dal/sdql) and egg should be considered.

<!-- - [Enumo](https://github.com/uwplse/ruler), https://github.com/moves-rwth/caesar  which uses egg -->

As for codegen, there are

- [Gaalop](https://github.com/CallForSanity/Gaalop)
- [GARAMON](https://github.com/vincentnozick/garamon) (2022)
  - [M2-GAmazing](https://github.com/IMAC-projects/M2-GAmazing) uses it
- [ganja.js/codegen](https://github.com/enkimute/ganja.js/tree/master/codegen) (2020)
  
For visualization, there are

- [ganja.js](https://github.com/enkimute/ganja.js)
- [enkimute/LookMaNoMatrices](https://github.com/enkimute/LookMaNoMatrices)
