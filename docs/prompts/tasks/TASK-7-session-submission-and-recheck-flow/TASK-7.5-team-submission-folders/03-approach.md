# Approach Prompt

Given the requirements and entities for this task:

Task: `7.5 Group each team's submission files in a team-specific Application Support folder so submitted snapshots, rechecks, and sticker eligibility can be reviewed without mixing team contexts.`

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

Add team-specific submission folder grouping so snapshots, rechecks, and sticker eligibility do not mix team contexts.

Validation expectation:

Swift Testing path scoping checks proving no team mixing.

Split trigger:

Split if submission path policy affects recheck and sticker services at the same time.

Do not build automatically unless explicitly asked.
