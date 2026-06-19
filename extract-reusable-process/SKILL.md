---
name: extract-reusable-process
description: Turn a recent human-agent interaction into a portable workflow description.
disable-model-invocation: true
---

Analyze the recent human-agent interaction and infer the reusable process behind
it.

Produce a generic skill description that teaches another agent how to carry out
the same kind of work with a human in a different context. Capture the purpose,
workflow, decision points, tradeoffs, iteration pattern, and expected output
shape.

Do not summarize the specific conversation. Do not mention project-specific
names, files, tools, or domain facts unless they are essential examples.
Abstract them into general roles and actions.

The description should be actionable: after reading it, a human and agent should
be able to collaborate through a similar process and produce a similar type
of result.
