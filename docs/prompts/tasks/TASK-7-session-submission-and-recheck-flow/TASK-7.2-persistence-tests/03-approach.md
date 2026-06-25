# Approach Prompt

Given the requirements and entities for this task:

Task: `7.2 Add failing persistence tests for storing each in-progress test case as its own JSON file under FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask), scoped by event, team, session, stage, and test case ID.`

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

Add failing Swift Testing coverage for per-test-case Application Support JSON draft storage.

Validation expectation:

Swift Testing with isolated temporary Application Support root.

Split trigger:

Split if storage layout helpers become reusable infrastructure.

Do not build automatically unless explicitly asked.
