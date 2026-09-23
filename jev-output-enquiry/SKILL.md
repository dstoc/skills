---
name: jev-output-enquiry
description: Use for narrow semantic questions about large diffs, CI logs, search results, or failed build/test output. Prefer deterministic checks for exact answers.
---

# Jev output enquiry

Use Jev when the output is large but the question is small and specific. Check exit codes and use `jq`, `grep`, or parsers for exact answers instead.

## Failed commands

Use `scripts/jev-run` (or `jev-run` on PATH) for commands with potentially large failure output:

```bash
jev-run \
  --noul 'What is the primary failure category?' \
  --choice assertion --choice compilation --choice environment \
  --choice timeout --choice other \
  -- cargo test --workspace -q
```

On success or failures below 8 KiB combined, the wrapper returns stdout and stderr separately without calling Jev. For larger failures, it prints the Jev answer and paths to the saved stdout/stderr logs. It always preserves the command's exit code.

Set `JEV_MIN_BYTES=16384` to change the threshold, or `JEV_MIN_BYTES=0` to query every failure.

## Diffs, logs, and searches

For repeatable output, pipe it to Jev before reading it:

```bash
git diff | jev ask - \
  --noul 'Does this diff change the public wire format?' \
  --filter-output answers
```

For expensive or nondeterministic output, save it once and use `jev ask ignored --state-file "$log"`.

## Question types

- **Yes/no:** `--noul 'Does this change the public API?'`
- **One category:** `--noul 'What failed?' --choice compilation --choice assertion --choice environment --choice other`. Include `other` if none may fit.
- **Ordered rating:** `--noul 'How broad is the impact?' --score 'one test' --score 'one package' --score 'entire suite'`. Give concrete levels from lowest to highest.

Add `--filter-output answers` to direct `jev ask` calls for concise output.

## Escalation

Inspect the relevant saved output when Jev's answer is uncertain, surprising, contradicts an exact check, or identifies a problem you need to fix. If Jev is unavailable, read the logs instead of retrying. Never send secrets or sensitive output to Jev.
