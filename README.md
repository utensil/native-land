# Native Land

[![Build Status](https://github.com/utensil/native-land/actions/workflows/main.yml/badge.svg)](https://github.com/utensil/native-land/actions/workflows/main.yml)

A monorepo for my native projects: Rust, Zig, C++...

The repo is organized as follows, strongly inspired by [Research Codebase Manifesto](https://www.moderndescartes.com/essays/research_code/):
 
- `yard-*`: experimental stuff per language
- `proj-*`: projects per language
- `core-*`: production-ready packages, applications per language
- `notebooks`: Jupyter notebooks, if there is a supported kernel
- `archived`: old stuff, not maintained anymore

The repo root can serve as a workspace for each build tool, like `cargo`, `xmake` etc.
