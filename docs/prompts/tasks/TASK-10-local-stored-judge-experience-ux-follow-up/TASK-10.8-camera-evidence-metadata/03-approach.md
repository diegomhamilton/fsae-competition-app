# Approach Prompt

Given the requirements and entities for this task:

Task: `10.8 Add camera/photo capture support for evidence-required steps, persisting captured file metadata with the test case JSON draft while keeping full media storage behind a reviewed storage policy.`

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

Add metadata-first camera/photo capture support for evidence-required steps.

Validation expectation:

Metadata persistence checks and manual capture smoke notes.

Split trigger:

Split if platform permissions or media storage policy enters scope.

Do not build automatically unless explicitly asked.
