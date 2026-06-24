# Entities Prompt

For this task:

Task: `7.1 Add failing coordinator tests for mock login completion, session selector routing, start session, resume session, stage selection, team switching, and restored context.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- FSAEInspectionChecklistTests/*CoordinatorTests.swift
- coordinator fixtures/helpers

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#7 Session, Submission, and Recheck Flow
- Subtask: TASK#7.1
- Expected PR title: `TASK#7.1: Coordinator Tests`
- Feature branch: `codex/inspection-event-session-flow`
- Suggested task branch: `codex/inspection-event-session-flow-7-1-coordinator-tests`
- Operation summary: Add failing Swift Testing coverage for session-flow coordinator behavior before coordinator implementation.
- Likely files or targets: FSAEInspectionChecklistTests/*CoordinatorTests.swift; coordinator fixtures/helpers
- Validation: Swift Testing failures first, then passing tests after coordinator implementation.
- Split trigger: Split if coordinator fixtures or navigation helpers exceed one focused test file group.
- Common instructions:
- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
