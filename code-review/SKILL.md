---
name: code-review
disable-model-invocation: true
description: Code and architecture review of a target or codebase
---

# Code Review

Review the specified target thoroughly. The target can be the entire codebase or a narrower subsystem, feature, module, package, or execution path.

If no narrower target is specified, review the entire codebase.

Identify the target and its boundaries. Inspect the relevant repository structure and trace important implementation paths before drawing conclusions. Inspect related code when needed to understand or validate the target. This can include its dependencies, callers, integrations, tests, and configuration.

Do not review unrelated code or report unrelated findings. If the target boundaries are unclear, state the scope assumptions you used. Do not modify the project.

## Code quality

Assess whether the target makes idiomatic use of its language, frameworks, and libraries. Look for:

* outdated or awkward patterns
* unnecessary complexity
* poor API design
* weak abstractions
* inefficient implementations
* inconsistent error handling
* code that is difficult to understand or maintain

Focus on meaningful improvements. Do not report stylistic preferences alone.

## Architecture

Assess whether the target divides responsibilities appropriately and has clear boundaries with related code. Look for:

* mixed responsibilities
* unclear or inappropriate boundaries
* unnecessary coupling or fragmentation
* oversized modules
* duplicated concepts
* missing abstractions
* abstractions that add little value

## Correctness and completeness

Look for:

* bugs
* broken features
* incomplete implementations
* ignored failures
* incorrect assumptions
* unhandled edge cases
* differences between documented and actual behavior

Trace real execution paths when practical. Distinguish confirmed defects from suspected risks.

## Dead code

Identify unused, obsolete, redundant, or unnecessarily complex code related to the target. Include:

* modules
* dependencies
* configuration
* abstractions

Use available tools and repository evidence where possible.

## Findings

Prioritize substantive findings. For each finding, include:

* category: `bug`, `architecture`, `code quality`, `incomplete`, or `dead code`
* severity: `high`, `medium`, or `low`
* location
* problem
* impact on the target
* recommended direction

Clearly distinguish confirmed defects from suspected risks.

End with:

* an overall assessment of the target
* a prioritized list of recommended improvements for the target
