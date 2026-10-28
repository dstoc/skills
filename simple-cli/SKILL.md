---
name: simple-cli
description: Build or simplify predictable command-line interfaces. Use for command structure, arguments, help, configuration, interactive setup, input/output, diagnostics, and cancellation behavior.
---

# Simple CLI

1. Read the existing commands and identify the user's main task. Keep a small, consistent command surface. Add options only for current needs. Preserve security and data-integrity guarantees.
2. Use an established argument parser. Provide useful --help text and copyable examples. Use consistent names, defaults, and configuration precedence. Reject invalid arguments with a clear usage error.
3. Support file paths and - for stdin or stdout where appropriate. Reserve stdout for requested output. Send diagnostics, progress, and prompts to stderr. Keep secrets out of arguments, diagnostics, and logs.
4. Make setup direct: validate answers, explain errors, and review consequential choices before saving. Keep ordinary operations usable in scripts. Do not silently prompt when input is piped or no interactive terminal is available.
5. For long-running or interactive commands, consider [OSC 7501 program status](https://www.superlogical.com/rex/docs/build/program-status) so the terminal can show progress, requests for input, and completion or failure. Emit status only to terminal-connected stderr, never redirected output. Keep normal messages and exit codes useful without terminal support.
6. Return zero on success and nonzero on failure. Use distinct exit codes only when callers need them. Explain what failed and what the user can do. State whether a write committed when failure occurs after publication.
7. Define cancellation, concurrency, and overwrite behavior. Preserve existing data until replacement succeeds. Never silently weaken authentication or transport security to recover from an error.
8. Keep development commands outside the normal interface. Test help, argument errors, exact stdout/stderr behavior, and consequential failure paths. Update user documentation when commands change.

Prefer fewer concepts and paths to review. Avoid custom parsing and speculative configuration.
