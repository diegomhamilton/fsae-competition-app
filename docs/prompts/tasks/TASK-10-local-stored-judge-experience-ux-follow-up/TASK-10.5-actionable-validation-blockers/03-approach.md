# Approach Prompt

Given the requirements and entities for this task:

Task: `10.5 Make validation blockers actionable by tapping or selecting a blocker to focus the missing outcome, note, measurement, or evidence control, then persist the correction immediately to the test case JSON draft.`

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

Make validation blockers selectable, focus missing controls, and persist corrections immediately.

Validation expectation:

Swift Testing focus routing and JSON draft persistence checks.

Split trigger:

Split if focus routing and persistence updates exceed one review context.

Do not build automatically unless explicitly asked.
