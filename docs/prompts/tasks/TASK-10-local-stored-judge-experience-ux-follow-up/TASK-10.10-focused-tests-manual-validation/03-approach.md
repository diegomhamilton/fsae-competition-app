# Approach Prompt

Given the requirements and entities for this task:

Task: `10.10 Add focused tests and manual validation for relaunch restore UX, actionable validation focus, camera evidence metadata, stopwatch timing, keyboard dismissal, VoiceOver operation, and common judge recovery paths.`

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

Add focused Swift Testing checks and manual validation for restore, blocker focus, evidence metadata, stopwatch, keyboard, VoiceOver, and recovery paths.

Validation expectation:

Swift Testing plus manual validation evidence.

Split trigger:

Keep as validation PR if implementation work is already large.

Do not build automatically unless explicitly asked.
