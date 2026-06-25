# Approach Prompt

Given the requirements and entities for this task:

Task: `9.5 Keep one feature branch and one PR per major feature by default; split into task branches only when file changes or review contexts become too broad.`

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

Document branch and PR split rules for feature branches and short-lived task branches.

Validation expectation:

Branch plan identifies split thresholds.

Split trigger:

Split when a PR exceeds 10 files or combines unrelated domains.

Do not build automatically unless explicitly asked.
