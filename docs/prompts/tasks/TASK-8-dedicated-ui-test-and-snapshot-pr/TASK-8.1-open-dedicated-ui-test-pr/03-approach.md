# Approach Prompt

Given the requirements and entities for this task:

Task: `8.1 Open a dedicated UI test PR after accessibility identifiers and stable navigation hooks exist.`

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

Open the dedicated UI automation and snapshot PR only after stable accessibility and navigation prerequisites exist.

Validation expectation:

Static prerequisite review against TASK#6 and TASK#7 outputs.

Split trigger:

Split if prerequisites are incomplete and require implementation fixes.

Do not build automatically unless explicitly asked.
