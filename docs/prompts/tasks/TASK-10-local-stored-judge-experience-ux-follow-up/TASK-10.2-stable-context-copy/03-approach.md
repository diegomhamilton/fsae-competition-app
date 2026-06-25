# Approach Prompt

Given the requirements and entities for this task:

Task: `10.2 Replace prototype header/background treatment and mock state copy with stable event, team, stage, and test case context that survives relaunch restore and makes the active local session obvious.`

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

Replace prototype copy and headers with persisted event/team/stage/test case context.

Validation expectation:

Relaunch restore shows clear active local session.

Split trigger:

Split if visual treatment and state plumbing both change heavily.

Do not build automatically unless explicitly asked.
