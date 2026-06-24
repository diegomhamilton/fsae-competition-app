# Approach Prompt

Given the requirements and entities for this task:

Task: `7.11 Implement sticker eligibility calculation from submitted stages and open rechecks.`

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

Implement sticker eligibility calculation from submitted stages and unresolved rechecks.

Validation expectation:

Swift Testing matrix for submitted, missing, open-recheck, and eligible states.

Split trigger:

Split if eligibility display UI changes are included.

Do not build automatically unless explicitly asked.
