# Agent Guidelines for this Repository

*Last updated 2025-06-25*

> **Purpose** – This file provides coding standards, build/test commands, and workflow guidelines for AI assistants and human contributors working in this repository.

---

## 1. Non-negotiable golden rules

### G-0: Always ask for clarification when unsure
- ✅ **May**: Ask for clarification before making changes when unsure about project-specific details
- ❌ **Must NOT**: Write changes or use tools when uncertain about project specifics

### G-1: Stay within designated code areas
- ✅ **May**: Generate code only in designated areas (`yard-rs/`, `yard-cpp/`, `yard-zig/`)
- ❌ **Must NOT**: Touch test files, CI configs, or core build scripts without permission

### G-2: Use anchor comments appropriately
- ✅ **May**: Add/update `AGENT-NOTE:` anchor comments near non-trivial edits
- ❌ **Must NOT**: Delete or mangle existing `AGENT-*` comments

### G-3: Follow project linting and style
- ✅ **May**: Follow lint/style configs (`rustfmt.toml`)
- ❌ **Must NOT**: Re-format code to any other style

### G-4: Get approval for large changes
- ✅ **May**: Ask for confirmation if changes affect >3 files or >300 LOC
- ❌ **Must NOT**: Refactor large modules without human guidance

### G-5: Maintain task context boundaries
- ✅ **May**: Stay within current task context
- ❌ **Must NOT**: Continue work from prior prompt after "new task"

### G-6: Use syntax-aware tools
- ✅ **May**: Use ast-grep (`sg`) for syntax-aware searches when available
- ❌ **Must NOT**: Fall back to text-only tools unless explicitly requested

---

## 2. Core Workflows

### Build & Test
- **Main build**: `just build` (builds all projects)
- **CI build**: `just ci` (includes coverage)
- **Test all**: `just test`
- **Single test**: `cd <project-dir> && just test` (e.g. `cd yard-rs/bevy-xp && just test`)

### Language-Specific
- **Rust**: `just clippy` (linting), `just fmt` (formatting)
- **C++**: `just run` (build & run), `just run-win` (Windows)
- **Zig**: `just test` in `yard-zig/basic-xp`

### GPU Projects
- Set `WGPU_BACKEND=dx12` (Windows) or `vulkan` (Linux/macOS)

---

## 3. CI Pipeline

Key workflows:
1. **main.yml**: Rust projects (ubuntu, windows, macos)
2. **cpp.yml**: C++ projects
3. **zig.yml**: Zig projects
4. **nb.yml**: Notebook testing
5. **runpod-monit.yml**: Scheduled monitoring

Common CI steps:
- Install toolchains (Rust nightly, xmake, asdf for Zig)
- Setup GPU backends (Vulkan SDK on Linux)
- Run project-specific tests
- Report coverage (Codecov for Rust)

---

## 4. Project Structure

| Directory       | Contents                          | Key Commands              |
|-----------------|-----------------------------------|---------------------------|
| `yard-rs/`      | Rust projects (bevy, candle etc) | `just test`, `just cov`   |
| `yard-cpp/`     | C++ implementations              | `just run`, `just run-win`|
| `yard-zig/`    | Zig experiments                  | `just test`               |
| `livebooks/`    | Documentation notebooks          | `just prep`, `just test` |

---

## 5. Code Style

### Rust
- **Formatting**: `rustfmt` with max_width=100, reorder_imports=true
- **Imports**: Group by crate (reorder_modules=true)
- **Types**: Prefer explicit types for clarity
- **Naming**: `snake_case` (vars), `PascalCase` (types)
- **Error Handling**: Use `Result`/`Option`; avoid `unwrap()` in production

### General
- **Comments**: Add `AGENT-NOTE:` for non-trivial changes
- **Documentation**: Include docstrings for public items
- **Performance**: Profile before optimizing

---

## 6. Toolchain Management

- **Rust**: Version pinned in `rust-toolchain.toml`
- **Zig**: Managed via asdf in CI
- **C++**: xmake for builds
- **Python**: Used in notebooks (uv for dependency management)

---

## 7. Commit Standards

- **Messages**: Use conventional commits (`feat:`, `fix:`, etc.)
- **Scope**: One logical change per commit
- **Tagging**: Mark AI-generated commits with `[AGENT]`
- **Review**: Human must review all changes before merging

🤖 Generated with [opencode](https://opencode.ai)