---
name: proposal-goal-subagents
description: Work through a proposal by starting a tracked /goal, reading the proposal, breaking it into milestone-sized tasks, and delegating each implementation milestone to fresh subagents instead of implementing directly in the main agent. Use when the user wants proposal-driven execution with explicit progress tracking and milestone-by-milestone delegation.
disable-model-invocation: true
---

# Proposal Goal Subagents

Use this skill when the user wants work driven by a proposal document and explicitly wants `/goal` tracking, milestone planning, and delegated implementation through subagents rather than direct local coding in the main agent.

## Workflow

1. Start a goal whose objective names the proposal path and the delegation constraint.
2. Read the proposal first. Do not delegate before you understand the requested API, behavior, non-goals, and verification targets.
3. Inspect the local codebase to map the proposal onto concrete files, current call sites, and likely tests.
4. Convert the proposal into milestone-sized implementation steps with clear file ownership, minimal overlap and detailed guidance.
5. Delegate each substantive implementation milestone to a **fresh** subagent; handle small tasks and minor fixes directly.
6. Review each returned diff locally before starting the next milestone that depends on it.
7. Run verification from the main agent after milestone work lands.
8. If verification exposes a substantial new issue from the delegated work, create one more narrow milestone and delegate that fix to a fresh subagent; handle small local fixes directly.
9. Mark the goal complete only after the proposal work is done or the remaining blockers are clearly identified.

## Delegation Rules

- Keep the main agent in orchestration mode: read, plan, review, verify, and integrate.
- Delegate substantive implementation milestones to fresh subagents. The main agent may handle small tasks, minor fixes, and routine integration work directly when creating a separate milestone would add unnecessary overhead.
- Use a subagent with a clean context (e.g. fork_turns = none) for each milestone. Prefer the first available model from this list unless the user asked for something different:
  - gpt-5.6-luna / xhigh
  - gemini-3.6-flash / medium
  - gpt-5.6-terra / low
  - claude-sonnet-4-6 / medium
- Give every worker a strict scope:
  - exact files it may edit
  - files it must not edit
  - the proposal requirement it is satisfying
  - validation expectations
- When complete, require the worker to report:
  - what was changed
  - files modified
  - validation performed and results
  - remaining issues or uncertainties
  - process feedback, when relevant: unclear or conflicting instructions, difficult commands or workflows, access or tooling problems, unexpected repository constraints, and suggestions for improving this skill or future delegation
- The main agent should capture and group process feedback across milestones, then summarize recurring themes and actionable improvements for the user at the end of the goal.
- Tell workers not to revert unrelated existing changes in the worktree.
- Do not proactively check in on a working subagent or ask what it is doing or has done. If waiting for a subagent, wait for the maximum duration available before polling or taking any other action.

## Milestone Design

Good milestones are:

- small enough to review in one pass
- limited to one layer or concern
- unlikely to conflict with parallel or later work
- directly traceable to a proposal section

Bad milestones are:

- “implement the whole proposal”
- mixed production and test rewrites without a reason
- broad repo-wide edits with unclear ownership

## Review Checklist

After each subagent returns, confirm:

- the changed files match the assigned scope
- the implementation matches the proposal’s specified requirements, behavior, and fallback or error handling, when applicable
- no unrelated behavior was folded in
- the next milestone assumptions are now valid

## Verification

- Run the narrowest relevant checks first.
- Separate new failures from pre-existing repo failures.
- If a delegated change introduces a substantial bug or type error, delegate one narrow cleanup milestone; patch small, local issues directly in the main agent.

## Response Pattern

While using this skill:

- tell the user you are starting a tracked goal
- explain that you will inspect the proposal before delegating
- provide short progress updates between milestones
- summarize completed milestones, verification status, remaining blockers, and recurring process feedback with actionable improvements at the end
