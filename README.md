# Native Land

[![CI (Rust)](https://github.com/utensil/native-land/actions/workflows/main.yml/badge.svg)](https://github.com/utensil/native-land/actions/workflows/main.yml) [![CI (C++)](https://github.com/utensil/native-land/actions/workflows/cpp.yml/badge.svg)](https://github.com/utensil/native-land/actions/workflows/cpp.yml)

[![codecov](https://codecov.io/gh/utensil/native-land/graph/badge.svg?token=MPli1CWOp4)](https://codecov.io/gh/utensil/native-land) [![DeepSource](https://app.deepsource.com/gh/utensil/native-land.svg/?label=code+coverage&show_trend=true&token=RINFELWOIDI0xeIlpAi2NAuG)](https://app.deepsource.com/gh/utensil/native-land/) [![DeepSource](https://app.deepsource.com/gh/utensil/native-land.svg/?label=active+issues&show_trend=true&token=RINFELWOIDI0xeIlpAi2NAuG)](https://app.deepsource.com/gh/utensil/native-land/)

A monorepo for my native projects: Rust, Zig, C++...

The repo is organized as follows, strongly inspired by [Research Codebase Manifesto](https://www.moderndescartes.com/essays/research_code/) with shorter names:
 
- `yard-*`: experimental stuff per language, avoid dependencies between and upon them, some code might graduate to `proj*` and `pkg-*`
- `proj`, `proj-*`: projects in general, or per language, may depend on `pkg-*`
- `pkg-*`: production-ready packages per language
  - in the case of Rust, it's named `crates` instead
- `notebooks`: Jupyter notebooks, if there is a supported kernel
- `archived`: old stuff, not maintained anymore

The repo root can serve as a workspace for each build tool, like `cargo`, `xmake` etc.
