---
name: design-gates
description: Identify engineering decisions that may exceed the task's delegated authority—one-way doors, architectural changes, new concepts or systems, contract changes, security boundaries, and lasting operational commitments. Surface significant choices and obtain needed agreement before implementation.
---

# Design gates

**Purpose:** Recognise when an implementation choice is actually a design decision that warrants discussion or explicit authorisation. A solution can be technically sound and still be a decision the implementer should not make unilaterally.

**Principle:** Make routine, reversible decisions autonomously. Expose consequential choices *before* committing to them. Treat the user's authorisation as a boundary, not merely the technical feasibility of a solution.

Use this check when proposing an approach, before making non-trivial changes, and whenever investigation uncovers a new design choice. Apply it alongside engineering discipline, especially when bounding impact and shaping a solution.

## 1. Establish the decision boundary

- Identify the requested outcome, constraints, and existing design intent.
- Distinguish what the user explicitly chose from implementation details delegated to the engineer.
- Determine whether the contemplated choice is necessary for the task or an optional expansion.
- Recognise prior, specific approval; do not repeatedly escalate the same agreed decision. Generic approval to implement a feature is not automatically approval for surprising architectural or security changes.

## 2. Look for consequential choices

Evaluate the *effects* of the proposed change, not its line count or terminology.

- **One-way doors:** Decisions expensive or unsafe to undo once deployed, adopted, or populated with data. Consider rollback *after real use*, not just whether the code can be reverted.
- **Architecture and ownership:** Replacing a major component; moving responsibilities across boundaries; changing execution, storage, communication, or deployment models; introducing new services, daemons, protocols, or control planes.
- **Conceptual expansion:** Adding a new abstraction, lifecycle, state machine, configuration dimension, intermediary, or general-purpose framework. Ask whether an existing concept could suffice and who must now understand or maintain the new one.
- **Contracts and compatibility:** Changing public APIs, CLI behaviour, formats, schemas, persistence, defaults, semantics, guarantees, or supported integrations. Include implicit contracts relied upon by callers and operators.
- **Lasting commitments:** Adding dependencies, infrastructure, background processes, state, vendor coupling, build/deployment requirements, recurring costs, monitoring, or migration obligations.
- **Security and failure model:** Altering privileges, credentials, trust/isolation boundaries, network exposure, data retention, failure propagation, concurrency, recovery, or durability.
- **Scope and alternatives:** A broader rewrite, opportunistic redesign, or new mechanism where a narrower solution may deliver the requested outcome.

A trigger is a reason to examine a decision, **not automatic evidence that the decision is wrong**.

## 3. Test reversibility and surprise

Ask:

1. Can the original design be restored easily *after this is released and used*? What happens to persisted data, users, integrations, and operations?
2. Does this establish a precedent or concept that later work will have to follow?
3. Does it materially change what the system guarantees, what can fail, or who must operate it?
4. Would an informed user reasonably expect to choose between credible alternatives?
5. Would the user be surprised to discover the decision in a completed diff?
6. Is there a smaller, more reversible way to achieve the requested outcome?

Do not mistake the ability to revert a Git commit for reversibility of a deployed decision.

## 4. Classify the decision

### Proceed

The choice is within the task's authorisation, fits established concepts and contracts, has limited consequences, and is straightforward to reverse. Make the change and validate it normally; no ceremony or approval request is needed.

### Discuss before choosing

The approach creates a meaningful tradeoff, a new system or concept, significant architectural drift, substantial long-term commitment, or scope expansion. Briefly describe alternatives and a recommendation; get alignment **before adopting the design**.

### Require explicit approval

The approach crosses a one-way door or materially changes security boundaries, external/public contracts, persistent data, compatibility guarantees, destructive behaviour, or high-impact operational commitments—unless that *specific decision and its consequences* were already authorised. Do not implement the gated part without authorisation.

If multiple classifications apply, choose the higher gate. Uncertainty about a consequential effect is itself a reason to investigate, and—if still unresolved—to discuss it.

## 5. Escalate the decision, not the entire task

When a gate triggers, report concisely:

- **Decision:** The concrete choice to be made.
- **Why it matters:** The new concept, altered contract, irreversible effect, or lasting commitment.
- **Alternatives:** Usually the minimal/status-quo-compatible approach and the proposed change, with salient tradeoffs.
- **Reversibility:** What rollback or migration would actually entail after use.
- **Recommendation:** The preferred option and why.
- **Needed:** Clarification, design alignment, or explicit approval of the named decision.

Continue safe investigation, tests, or unrelated authorised work where possible. Do not silently implement the gated choice, bury it in a plan, or treat silence as approval. Once resolved, preserve the decision and rationale in the appropriate existing plan, issue, or documentation; do not create a heavyweight decision record by default.

## 6. Avoid false gates

- Do not demand approval for every new function, internal type, dependency update, or large diff. Assess actual commitments and consequences.
- Do not escalate decisions the user has already made explicitly, except to surface newly discovered material consequences.
- Do not classify routine bug fixes as architectural decisions merely because they touch important code.
- Do not create a decision gate as a substitute for doing engineering analysis or finding simpler alternatives.
- Do not assume the smallest diff is the safest choice; local patches can entrench irreversible behaviour.
- Do not present a single preferred solution as if alternatives were impossible when material alternatives exist.

## Quick examples

| Proposed change | Likely outcome | Reason |
| --- | --- | --- |
| Fix an internal bug without changing established behaviour | Proceed | Expected, local, reversible |
| Add a modest helper within an existing abstraction | Proceed | No new conceptual or operational commitment |
| Introduce a queue/worker subsystem to solve a local scheduling issue | Discuss | New lifecycle, failure modes, and operations |
| Replace the execution or network-security architecture | Discuss or explicit approval | Cross-cutting architectural/security impact |
| Break an existing public API or rewrite persistent state without an established migration | Explicit approval | External contract and one-way-door risk |
| Implement a previously agreed breaking change within its approved bounds | Proceed | The consequential decision has already been made |

**End-state check:** Has the implementation crossed a design boundary that a reasonable reviewer would expect to have been discussed? If yes, stop at that boundary and surface it before proceeding.