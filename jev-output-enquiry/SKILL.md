---
name: jev-output-enquiry
description: Use when inspecting large diffs, CI logs, search results, or failed build/test output and only a specific semantic judgment, classification, or score is needed. Prefer exit codes and deterministic parsing for exact checks.
---

# Jev output enquiry

Use Jev to answer narrow semantic questions **without loading large raw output into context**. Do not invoke it just because a command produces output.

## Exact checks first

Exit codes determine command success. Use `jq`, `grep`, parsers, and shell operations for exact checks. Use Jev for semantic questions that these cannot answer.

## Commands that may fail

For expensive commands whose failure output may need semantic triage, use the bundled `scripts/jev-run` wrapper (or `jev-run` if installed on PATH):

```bash
jev-run \
  --noul 'What is the primary failure category?' \
  --choice assertion --choice compilation --choice environment \
  --choice timeout --choice other \
  -- cargo test --workspace -q
```

The wrapper captures **stdout and stderr separately**. On success it replays both streams without calling Jev. On failure below **8 KiB combined**, it replays both streams and retains separate logs. For larger failures it sends Jev a JSON state with distinct `stdout`, `stderr`, and `exit_code` fields, returning only the compact answer and saved log paths. The original command exit code is preserved in every case. Set `JEV_MIN_BYTES=16384` to change the combined threshold, or `JEV_MIN_BYTES=0` to classify every failure. Metadata goes to stderr; raw stdout is never mixed with raw stderr in the saved files. Since output is buffered, original interleaving is not preserved. The wrapper accepts `--questions` and `--questions-file` as well as single-question flags.

## Diffs, logs, and searches

For cheap, repeatable output, query it directly **before reading it**:

```bash
git diff | jev ask - \
  --noul 'Does this diff change the public wire format?' \
  --filter-output answers
```

For expensive or nondeterministic output, save it once and use `jev ask ignored --state-file "$log"`. With `jev-run`, inspect the separately saved `stdout_log` and `stderr_log` paths if escalation is needed; remove the containing log directory when finished. The JSON state passed to Jev includes the exit code and both named streams. Do not use the wrapper with secret-bearing output.

## Questions and criteria

For one question, use `--noul 'yes/no question'`, `--noul 'which category?' --choice label ...`, or `--noul 'how much?' --score 'lowest' --score 'higher' ...`.

For **multiple independent questions about the same text**, use one `--questions` JSON object. Each key is the answer name; each question has a `type`, self-contained `instructions`, and `criteria` where required:

```bash
gh run view "$RUN_ID" --log-failed 2>&1 |
  jev ask - --questions '{
    "failure": {
      "type": "choice",
      "instructions": "What is the primary cause of this CI failure?",
      "criteria": {
        "compilation": "compiler or linker failure",
        "assertion": "test assertion or snapshot mismatch",
        "environment": "missing dependency, configuration, or infrastructure",
        "other": null
      }
    },
    "transient": {
      "type": "noul",
      "instructions": "Is there evidence this failure is transient rather than a reproducible code failure?"
    },
    "scope": {
      "type": "score",
      "instructions": "How broadly does the failure affect the test suite?",
      "criteria": [
        "one test or one isolated step",
        "multiple tests in one package",
        "multiple packages or the entire pipeline"
      ]
    }
  }' --filter-output answers
```

- `noul`: yes/no probability; `criteria` optional (may describe `"true"` and `"false"`).
- `choice`: **required object** mapping each label to a description or `null`. Include `other` when none may fit. Choose one primary alternative; use separate `noul` questions for overlapping conditions.
- `score`: **required ordered array** of at least two concrete levels, lowest first. Do not use an object keyed by score.
- The answer names (`failure`, `transient`, `scope`) are for matching results, **not** substitutes for complete instructions. Questions run independently in one request; they cannot refer to each other's answers. `freeform` is not supported.

Use `--questions-file questions.json` instead of inline JSON if quoting becomes cumbersome. `jev-run --questions '...' -- command` also works; the wrapper queries only when the command fails.

## Escalation

Inspect saved output when an answer is uncertain or surprising, contradicts an exact check, matters enough to require verification, or identifies an issue you must fix. Read only relevant sections where possible. If Jev is unavailable, inspect saved output instead of repeatedly retrying. Never send secrets or sensitive output to Jev.

**Rule:** Use Jev when the output is large, but the question is small and well-defined.
