# Approach Prompt

Given the requirements and entities for this task:

Task: `7.10 Implement RecheckService so failed test cases create open recheck items and accepted reviews close them.`

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

Implement recheck lifecycle from failed test case to open item to accepted review closure after stage submission service boundaries are in place.

Validation expectation:

Swift Testing for failed case creation, open state, accepted review closure, and references.

Split trigger:

Split if UI review flow or coordinator/view draft integration is introduced with service behavior.

Do not build automatically unless explicitly asked.
