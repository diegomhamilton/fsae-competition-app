# Approach Prompt

Given the requirements and entities for this task:

Task: `9.4 Ensure each implementation PR uses the PR 1 description template with Summary, Scope, Notes, and Validation, including manual validation notes, test command output, linked .feature scenarios, and squash-merge guidance.`

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

Standardize implementation PR descriptions around Summary, Scope, Notes, Validation, scenario links, and squash guidance.

Validation expectation:

PR description checklist review.

Split trigger:

Keep separate from code PRs when possible.

Do not build automatically unless explicitly asked.
