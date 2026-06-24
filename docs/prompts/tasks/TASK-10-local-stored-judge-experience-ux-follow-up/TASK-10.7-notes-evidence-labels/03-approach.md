# Approach Prompt

Given the requirements and entities for this task:

Task: `10.7 Clarify notes and evidence states with labels such as Add Evidence, 1 Evidence, Required Evidence Missing, Add Note, and Edit Note, and ensure each state round-trips through the local test case JSON draft.`

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

Clarify notes/evidence state labels and persist each state through JSON draft round-trips.

Validation expectation:

Swift Testing label state matrix and JSON round-trip checks.

Split trigger:

Split if evidence state model changes independently.

Do not build automatically unless explicitly asked.
