# Approach Prompt

Given the requirements and entities for this task:

Task: `8.4 Add dedicated UI automation checks that assert required controls and statuses are accessible by stable identifiers rather than localized labels.`

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

Assert controls and statuses by stable accessibility identifiers rather than localized labels.

Validation expectation:

Tests fail when required identifiers are missing or unstable.

Split trigger:

Split if app code needs identifier fixes.

Do not build automatically unless explicitly asked.
