---
name: run-in-nw-sandbox
description: Use when network access is blocked and there is not a more specific skill
---

This "agent" container provides very limited network access, wider access is available in the "network sandbox" via a limited set of commands.

## 1. Review command policy

- Inspect Rego policy at `/opt/config/nw_sandbox/` using shell commands (`ls`, `rg`, or `less`).
- The decision query is `data.sandbox.main.allow`, so check `main.rego` and the command package (for example `package sandbox.curl`).
- Match arguments against Rego rules in the command package (for example `package sandbox.curl`) and adjust commands accordingly.

## 2. Review allowed domains

- Inspect allowed domains at `/opt/config/nw_sandbox/domains.lst`.


## 3. Run in the sandbox

Use:

```bash
run-in-nw-sandbox [--keep-env=VAR] -- <command> <args>
```

E.g.

```bash
run-in-nw-sandbox -- cargo fetch
```

Do not omit the `--` delimiter.

### Core Usage Rules

- Always include the `--` delimiter between helper options and the command.
- Forward variables with `--keep-env` and ensure they exist in the current shell.
- Use `--keep-env=VAR` or `--keep-env=VAR1,VAR2`.
- Keep environment variables only when explicitly forwarded.

## 4. Troubleshoot

1. Identify whether the error is syntax, policy, or network.
2. If the error mentions a missing `--` delimiter, add it.
3. If the error mentions missing local env vars, set them and retry.
4. If the error indicates a policy violation, inspect the Rego policy directory.
5. If the error indicates a network block, inspect the domain allowlist.

