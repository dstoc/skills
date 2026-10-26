---
name: simple-web-ui
description: Build or simplify web interfaces with static HTML, CSS, and native JavaScript modules. Use for task flows, setup screens, settings, forms, and approval interfaces that should remain small and easy to audit.
---

# Simple Web UI

1. Read the existing interface and identify the user's main task. Keep the fewest screens, states, and actions needed to complete it. Preserve security and approval guarantees.
2. Default to static HTML, CSS, and native JavaScript modules. Use browser APIs and semantic HTML. Avoid frameworks, build steps, and dependencies without a concrete need. Follow an established project stack when changing an existing app.
3. Make the main action clear. Use short labels and direct instructions. Show secondary settings only when needed. Keep implementation details out of ordinary user flows.
4. Use focused modules and direct control flow. Separate rendering, state, and external interactions where this makes the code easier to follow. Avoid generic component or state frameworks for a small interface.
5. Handle loading, empty results, failure, cancellation, and completion. Prevent duplicate actions. Preserve user input after recoverable errors. Explain failures and the next useful action.
6. Support keyboard use, visible focus, labeled controls, and small screens. Render untrusted text as text. Keep validation and authorization at their trust boundaries.
7. Keep compatibility probes and development tools outside the production interface. Check the main flow and consequential failure paths. Inspect the rendered page at desktop and mobile widths.

Prefer fewer concepts and paths to review. Do not remove checks that enforce security guarantees.
