# Approach Prompt

Given the requirements and entities for this task:

Task: `7.4 Implement an actor-isolated JSON file persistence service that creates the Application Support folder tree, writes each test case draft atomically, deletes or archives stale draft files after submission, and restores drafts after app relaunch.`

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

Implement actor-isolated JSON draft persistence with atomic writes, folder creation, stale draft cleanup, and relaunch restore.

Validation expectation:

Swift Testing for actor-isolated writes, restore, atomic replacement, and cleanup.

Split trigger:

Split from schemas if implementation touches more than persistence service plus tests.

Do not build automatically unless explicitly asked.
