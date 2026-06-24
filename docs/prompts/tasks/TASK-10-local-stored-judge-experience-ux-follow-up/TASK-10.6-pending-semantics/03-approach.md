# Approach Prompt

Given the requirements and entities for this task:

Task: `10.6 Review Pending semantics so incomplete required steps are represented as derived draft state rather than a confusing judge decision when Pass, Fail, and N/A are the actual choices.`

Propose an approach that keeps the PR reviewable.

Include:

- The smallest useful implementation or documentation slice
- Test-first steps using Swift Testing where code behavior is involved
- Dedicated UI automation only when this task is part of TASK#8
- Manual validation ownership and evidence to capture
- How the work maps back to the feature scenarios or OpenSpec specs
- What remains out of scope for a follow-up PR
- When to split into a task branch

Preferred operation:

Clarify Pending as derived incomplete state rather than a judge-selected outcome.

Validation expectation:

Swift Testing proves Pass/Fail/N/A are decisions and incomplete is derived.

Split trigger:

Split if migration from stored pending values is needed.

Do not build automatically unless explicitly asked.
