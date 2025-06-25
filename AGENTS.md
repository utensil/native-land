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

### C++
- Follow .clang-format rules (if present)
- Use modern C++ standards (C++17/20 where available)

### Zig
- Follow official Zig style guide
- Use error unions for error handling

### General
- **Comments**: Add `AGENT-NOTE:` for non-trivial changes
- **Documentation**: Include docstrings for public items
- **Performance**: Profile before optimizing

---

## 6. Completion Checklist

Before considering any task complete, ensure:

### For Rust Projects
1. `just fmt` - Format code correctly
2. `just clippy` - Fix all linter warnings
3. `just test` - Pass all tests locally
4. `just ci` - Verify CI pipeline would pass

### For C++ Projects
1. `just run` - Build and run successfully
2. `just run-win` - Verify Windows compatibility (if applicable)

### For Zig Projects
1. `just test` - Pass all tests
2. Manual review - Zig's comptime requires careful verification

### All Projects
- Verify no debug prints remain
- Confirm no secrets are exposed
- Check GPU compatibility if applicable

---

## 6. Toolchain Management

- **Rust**: Version pinned in `rust-toolchain.toml`
- **Zig**: Managed via asdf in CI
- **C++**: xmake for builds
- **Python**: Used in notebooks (uv for dependency management)

---

## 7. Commit Standards

### Message Format
```
<type>: <short description> [AGENT]

<detailed summary>
```

### Required Elements
- **Type**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, or `chore`
- **Short Description**: Under 50 characters
- **Detailed Summary**:
  - Why the change was made
  - Affected components
  - Verification steps taken
  - Any remaining TODOs

### Examples
```
feat: add GPU memory tracking [AGENT]

- Implemented Vulkan memory allocation tracking
- Added metrics reporting to Prometheus
- Verified with `just test` and manual inspection
- Remaining: Windows DX12 support (tracked in #123)
```

🤖 Generated with [opencode](https://opencode.ai)