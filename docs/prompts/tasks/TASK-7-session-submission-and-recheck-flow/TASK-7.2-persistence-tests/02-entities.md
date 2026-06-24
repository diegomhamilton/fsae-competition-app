# Entities Prompt

For this task:

Task: `7.2 Add failing persistence tests for storing each in-progress test case as its own JSON file under FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask), scoped by event, team, session, stage, and test case ID.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- Persistence tests
- temp directory helpers
- draft path helpers

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#7 Session, Submission, and Recheck Flow
- Subtask: TASK#7.2
- Expected PR title: `TASK#7.2: Persistence Tests`
- Feature branch: `codex/inspection-event-session-flow`
- Suggested task branch: `codex/inspection-event-session-flow-7-2-persistence-tests`
- Operation summary: Add failing Swift Testing coverage for per-test-case Application Support JSON draft storage.
- Likely files or targets: Persistence tests; temp directory helpers; draft path helpers
- Validation: Swift Testing with isolated temporary Application Support root.
- Split trigger: Split if storage layout helpers become reusable infrastructure.
- Common instructions:
- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
