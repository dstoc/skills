---
name: rust-dependencies
description: Use when you need to run `cargo install`, `cargo add`, `cargo search` or any cargo command fails with a network error
---

# Rust Dependencies

## Overview

Follow the local workflow for Rust dependency updates: check current crate versions with `cargo search <simple-string>`, manually edit `Cargo.toml`, then fetch crates using the approved network path.

## Workflow

1. Use `cargo search <simple-string>` through the network sandbox to check the latest crate version before adding or updating a dependency:

```bash
run-in-nw-sandbox -- cargo search serde_json
```

2. Edit `Cargo.toml` to add or update dependencies.
3. Fetch crates using the approved network path:

```bash
run-in-nw-sandbox -- cargo fetch
```

4. Continue with normal local builds/tests (no network required).

## Guardrails

- Assume the only allowed Cargo network commands are `cargo search <simple-string>` and `cargo fetch`, and both must be run through `run-in-nw-sandbox`.
- Use `cargo search <simple-string>` to check latest crate versions. Keep the search query to one simple token such as `serde_json`, `tokio`, or `clap`; do not pass flags, registry overrides, or multi-token queries.
- Always include the `--` delimiter between `run-in-nw-sandbox` options and the command.
- Forward environment variables only when explicitly required, using `--keep-env=VAR` (or `--keep-env=VAR1,VAR2`) and ensure they are set before forwarding.
- Do not suggest other Cargo network commands (for example `cargo update`, `cargo add`, or `cargo install`) unless the user explicitly confirms network access for them.
