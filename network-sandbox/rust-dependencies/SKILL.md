---
name: rust-dependencies
description: Manage Rust/Cargo dependencies in this environment. Use when adding, updating, or fetching crates, editing `Cargo.toml`, or working within the constraint that the only approved network command is `cargo fetch` via `run-in-nw-sandbox`.
---

# Rust Dependencies

## Overview

Follow the local workflow for Rust dependency updates: manually edit `Cargo.toml`, then fetch crates using the only approved network command.

## Workflow

1. Edit `Cargo.toml` to add or update dependencies.
2. Fetch crates using the approved network path:

```bash
run-in-nw-sandbox -- cargo fetch
```

3. Continue with normal local builds/tests (no network required).

## Guardrails

- Assume the only allowed network command is `cargo fetch` and it must be run through `run-in-nw-sandbox`.
- Always include the `--` delimiter between `run-in-nw-sandbox` options and the command.
- Forward environment variables only when explicitly required, using `--keep-env=VAR` (or `--keep-env=VAR1,VAR2`) and ensure they are set before forwarding.
- Do not suggest other Cargo network commands (for example `cargo update`, `cargo add`, or `cargo install`) unless the user explicitly confirms network access for them.
