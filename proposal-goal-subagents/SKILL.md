---
name: proposal-goal-subagents
description: Work through a proposal by starting a tracked /goal, reading the proposal, breaking it into milestone-sized tasks, and delegating each implementation milestone to fresh subagents instead of implementing directly in the main agent. Use when the user wants proposal-driven execution with explicit progress tracking and milestone-by-milestone delegation.
---

# Proposal Goal Subagents

Use this skill when the user wants work driven by a proposal document and explicitly wants `/goal` tracking, milestone planning, and delegated implementation through subagents rather than direct local coding in the main agent.

## Workflow

1. Start a goal whose objective names the proposal path and the delegation constraint.
2. Read the proposal first. Do not delegate before you understand the requested API, behavior, non-goals, and verification targets.
3. Inspect the local codebase to map the proposal onto concrete files, current call sites, and likely tests.
4. Convert the proposal into milestone-sized implementation steps with clear file ownership and minimal overlap.
5. Delegate each implementation milestone to a **fresh** subagent.
6. Review each returned diff locally before starting the next milestone that depends on it.
7. Run verification from the main agent after milestone work lands.
8. If verification exposes a new issue from the delegated work, create one more narrow milestone and delegate that fix to a fresh subagent.
9. Mark the goal complete only after the proposal work is done or the remaining blockers are clearly identified.

## Delegation Rules

- Keep the main agent in orchestration mode: read, plan, review, verify, and integrate.
- Do not implement the milestone directly in the main agent when the user asked for delegated implementation.
- Use a **fresh `claude-sonnet-4-6` or `gpt-5.4-mini` subagent** for each milestone unless the user asked for a different model.
- Give every worker a strict scope:
  - exact files it may edit
  - files it must not edit
  - the proposal requirement it is satisfying
  - validation expectations
- Tell workers they are not alone in the codebase and must not revert unrelated changes.
- Prefer milestone boundaries such as:
  - core API/plumbing
  - host integration
  - tests
  - verification follow-up fix

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

## Suggested Main-Agent Loop

1. `create_goal`
2. read proposal and surrounding code
3. `update_plan` with proposal-derived milestones
4. `spawn_agent` for milestone 1
5. wait, review returned changes, and verify the milestone shape
6. `spawn_agent` for the next milestone
7. repeat until implementation is complete
8. run final verification locally
9. `update_goal(status=\"complete\")`

## Review Checklist

After each subagent returns, confirm:

- the changed files match the assigned scope
- the implementation matches the proposal’s API and fallback semantics
- no unrelated behavior was folded in
- the next milestone assumptions are now valid

## Verification

- Run the narrowest relevant checks first.
- Separate new failures from pre-existing repo failures.
- If a delegated change introduces a real bug or type error, delegate one narrow cleanup milestone instead of patching locally.

## Response Pattern

While using this skill:

- tell the user you are starting a tracked goal
- explain that you will inspect the proposal before delegating
- provide short progress updates between milestones
- summarize completed milestones, verification status, and remaining blockers at the end
