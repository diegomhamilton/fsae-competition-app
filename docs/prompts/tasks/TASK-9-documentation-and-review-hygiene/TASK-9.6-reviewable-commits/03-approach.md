# Approach Prompt

Given the requirements and entities for this task:

Task: `9.6 Split tasks across distinct commits so each completed task or tightly related task pair has a reviewable checkpoint.`

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

Define task-sized commit guidance so each checkpoint is reviewable.

Validation expectation:

Commit list maps to tasks and validation.

Split trigger:

Split branches if commits are still too hard to review in one PR.

Do not build automatically unless explicitly asked.
