# Approach Prompt

Given the requirements and entities for this task:

Task: `7.6 Break each coordinator into a different task PR: Implement AppCoordinator, InspectionEventCoordinator, SessionSelectionCoordinator, and InspectionExecutionCoordinator.`

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

Implement coordinators as separately reviewable task PRs or task branches.

Validation expectation:

Swift Testing coordinator route and intent checks.

Split trigger:

Always split if all four coordinators push the PR over 10 files or one reviewer cannot inspect flow safely.

Do not build automatically unless explicitly asked.
