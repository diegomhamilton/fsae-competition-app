# Approach Prompt

Given the requirements and entities for this task:

Task: `7.1 Add failing coordinator tests for mock login completion, session selector routing, start session, resume session, stage selection, team switching, and restored context.`

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

Add failing Swift Testing coverage for session-flow coordinator behavior before coordinator implementation.

Validation expectation:

Swift Testing failures first, then passing tests after coordinator implementation.

Split trigger:

Split if coordinator fixtures or navigation helpers exceed one focused test file group.

Do not build automatically unless explicitly asked.
