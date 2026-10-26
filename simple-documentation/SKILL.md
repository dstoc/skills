---
name: simple-documentation
description: Write or simplify user-facing technical documentation. Use for READMEs, quick starts, setup instructions, and usage guides that should explain value and help readers complete a task without unnecessary detail.
---

# Simple Documentation

1. Identify the reader and the task. Read the relevant implementation and existing documentation before describing behavior.
2. Start with what the system does and why it is useful. Use concrete outcomes. Avoid implementation inventories and unsupported claims.
3. Give the shortest complete path to a useful result. State prerequisites before the steps that need them. Distinguish using an existing deployment from hosting one.
4. Explain how the system works at a high level. Connect its design to practical benefits. State the trust boundaries and limitations needed to understand those benefits.
5. Use realistic, copyable examples. Show the command or action, the expected result, and the next step when needed. Keep secrets out of examples that could expose them through logs or shell history.
6. Put everyday use first. Link to separate configuration, operator, design, and development details. Keep optional paths secondary. Explain important requirements and limitations once.
7. Use short paragraphs, direct sentences, and consistent terms. Use numbered lists for procedures. Explain technical terms only when the reader needs them. Apply precise-writing when available.
8. Verify commands, paths, links, UI labels, and expected behavior against the implementation. Walk through the main procedure for missing steps. Remove stale instructions, repetition, and speculative features.

Prefer the fewest explanations needed for confident use. Preserve details that affect correctness, security, or the reader's decisions.
