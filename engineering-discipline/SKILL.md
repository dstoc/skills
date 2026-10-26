---
name: engineering-discipline
description: Use for any non-trivial engineering work.
---

Understand the intent. Explain the gap. Bound the change. Simplify the design. Encode correctness. Change minimally. Prove it.

1. **Orient**
   - Validate the task: confirm the problem, goal, or opportunity is real and correctly framed.
   - Observe the current state directly and capture relevant evidence before changing it.
   - For bugs, reproduce the failure.
   - Establish the desired outcome, contract, invariants, and acceptance criteria.
   - Recover relevant intent from tests, history, docs, surrounding code, and prior constraints.
   - Distinguish deliberate trade-offs from accidents or obsolete assumptions.

2. **Explain**
   - Identify why the current state differs from the desired state.
   - For bugs, find the **root cause**: trace the symptom back to the first thing that went wrong.
   - For features, refactors, or migrations, identify the underlying structural reason the desired outcome is difficult or impossible today.
   - Test assumptions against evidence rather than guessing.
   - If repeated attempts fail under the same premise, question the premise.

3. **Bound**
   - Map the change surface: producers, consumers, APIs, state, persistence, integrations, tests, docs, and dependencies.
   - Identify external contracts and compatibility obligations.
   - Identify relevant constraints such as concurrency, security boundaries, and external dependencies.
   - Identify important failure modes and the cost of getting the change wrong.
   - Understand reversibility and migration requirements.

4. **Shape**
   - Design the simplest correct end state.
   - Ask what the system would look like if the requirement had existed from the beginning.
   - Subtract obsolete complexity before adding mechanisms.
   - Choose types, data structures, ownership, and boundaries that make the domain clear.
   - Eliminate unnecessary shared state, indirection, and abstractions.
   - Encode correctness structurally: make invalid states difficult or impossible, validate at boundaries, and prefer guarantees over conventions.
   - Design operations to be idempotent and recovery-friendly where appropriate.
   - Compare competing designs when the right answer is genuinely unclear.

5. **Change**
   - Make the smallest coherent change that reaches the intended end state.
   - Prefer reversible changes and bounded failure domains.
   - Work in small, independently verifiable increments.
   - Migrate callers and remove obsolete APIs when compatibility is not required.
   - Automate non-trivial mechanical work rather than performing it manually.
   - Avoid temporary architecture that survives only because it was convenient during implementation.

6. **Prove and learn**
   - Test observable behavior against the contract, not implementation details.
   - Verify the real artifact or effect rather than proxies such as “it compiles.”
   - Check the wider change surface, not only the original path.
   - Make important verification deterministic and rerunnable.
   - For measurements, explain what the numbers mean and what limits them.
   - Remove temporary scaffolding and workarounds.
   - Improve observability when diagnosis was unnecessarily difficult.
   - Encode lessons into types, checks, tooling, process, or architecture so the same failure is harder to repeat.