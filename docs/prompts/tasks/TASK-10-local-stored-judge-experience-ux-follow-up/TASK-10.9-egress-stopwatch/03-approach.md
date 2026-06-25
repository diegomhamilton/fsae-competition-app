# Approach Prompt

Given the requirements and entities for this task:

Task: `10.9 Add stopwatch-style timing support for egress-test measurement steps, including start, stop, reset, manual override, validation against the allowed range, draft persistence, and accessible announcements.`

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

Add egress stopwatch timing with manual override, range validation, draft persistence, and accessibility announcements.

Validation expectation:

Swift Testing timer/range/persistence checks and accessibility manual note.

Split trigger:

Split if timer engine and UI integration both grow.

Do not build automatically unless explicitly asked.
