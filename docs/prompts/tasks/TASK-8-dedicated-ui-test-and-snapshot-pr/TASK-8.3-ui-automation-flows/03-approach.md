# Approach Prompt

Given the requirements and entities for this task:

Task: `8.3 Add dedicated UI automation coverage for login, session selector, stage navigation, test case navigation, test step editing, validation blocking, team switching, recheck review, and sticker eligibility.`

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

Add dedicated UI automation flows for the full judge inspection journey.

Validation expectation:

UI automation run on selected simulator.

Split trigger:

Split by flow family if file count exceeds 10 or failures are hard to isolate.

Do not build automatically unless explicitly asked.
