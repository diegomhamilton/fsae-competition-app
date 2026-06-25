# Approach Prompt

Given the requirements and entities for this task:

Task: `8.5 Add snapshot tests for test step, test case, stage list, validation blocked, recheck required, and sticker eligible states where practical.`

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

Add Swift Testing-compatible snapshots for high-value inspection states.

Validation expectation:

Swift Testing snapshot command with controlled simulator/runtime.

Split trigger:

Split if snapshot dependency or baselines create large diffs.

Do not build automatically unless explicitly asked.
