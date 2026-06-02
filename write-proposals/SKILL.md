---
name: write-proposals
description: Draft new proposal documents for a codebase in the local proposal style. Use when the user wants a new proposal written before implementation, or wants an idea turned into a structured design/proposal document with motivation, problem statement, proposal, non-goals, verification, and success criteria.
---

# Write Proposals

Use this skill when the user wants a new proposal document written or wants a rough idea turned into a concrete implementation proposal before coding starts.

## Workflow

1. Inspect one or two nearby proposals in the repo to match local tone, section order, and level of detail.
2. Read the relevant code before writing the proposal. Do not propose APIs or file changes blindly.
3. Identify the current behavior, the concrete problem, and the narrowest change that solves it.
4. Write the proposal around one real use case first. Generalize only as far as the codebase actually needs.
5. Include explicit fallback behavior, non-goals, verification, and success criteria.
6. If the proposal implies implementation sequencing, include a suggested implementation shape or migration plan.

## Proposal Shape

Prefer this structure unless the repo clearly uses another format:

1. `# Proposal: ...`
2. `## Motivation`
3. `## Problem statement`
4. `## Proposal`
5. focused subsections for naming, semantics, storage location, or migration details
6. `## Non-goals`
7. `## Verification`
8. `## Success criteria`

Optional sections:

- `## Suggested implementation shape`
- `## Migration plan`
- `## Future expansion`

## Writing Rules

- Be concrete about current files, current behavior, and the exact pain point.
- Prefer narrow extension points over abstract frameworks.
- State decline and fallback semantics explicitly when proposing hooks, delegates, or overrides.
- Separate proposal facts from future possibilities.
- Keep non-goals real and protective, not filler.
- Verification should describe observable checks, not vague “test it” language.
- Success criteria should be short, binary, and implementation-facing.

## Scope Control

Good proposal behavior:

- solves one clear problem
- introduces the minimum new API surface
- preserves existing behavior when the new path is unused
- names the first extraction target or first caller

Bad proposal behavior:

- redesigning a subsystem without a present need
- proposing generic extensibility without a real first use case
- mixing implementation details with speculative future architecture

## Code-Reading Expectations

Before drafting, inspect:

- the current implementation file(s)
- the nearest host or caller integration point
- any existing tests that express the current behavior
- one or two nearby proposals for style calibration

If important facts are missing, gather more code context before writing.

## Output Expectations

The finished proposal should:

- read like a document ready to commit under `docs/proposals/`
- mention real file paths and code shapes from the repo
- explain why the chosen design is narrower or safer than obvious alternatives
- give implementation guidance without turning into a patch
