# Approach Prompt

Given the requirements and entities for this task:

Task: `10.3 Refine the test case screen so the primary next judge action is visually dominant: compact case summary, actionable validation message, and focused step editor for one-step cases.`

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

Refine test case screen around the judge's next action, compact summary, validation message, and focused one-step editor.

Validation expectation:

Swift Testing and manual checks for one-step and multi-step cases.

Split trigger:

Split if editor refactor touches step models or persistence.

Do not build automatically unless explicitly asked.
