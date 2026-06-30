# TASK#7.1 SPDD Prompt Run

Task: `7.1 Add failing coordinator tests for mock login completion, session selector routing, start session, resume session, stage selection, team switching, restored context, and store-backed draft save/restore.`

Purpose: Add failing Swift Testing coverage for session-flow coordinator behavior before coordinator implementation, including the discovered gap where coordinators/views must connect to InspectionEventStore for draft save/restore.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: FSAEInspectionChecklistTests/*CoordinatorTests.swift; coordinator fixtures/helpers; store-backed draft fixtures
- Validation: Swift Testing failures first, then passing tests after coordinator/view store integration; stage submission wiring remains out of scope.
- Split trigger: Split if coordinator fixtures, store fixtures, or navigation helpers exceed one focused test file group.

Expected PR title:

`TASK#7.1: Coordinator Tests`

Branch:

`codex/inspection-event-session-flow-7-1-coordinator-tests`

Common instructions:

- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Link coordinators/views to InspectionEventStore for draft save/restore before submission/recheck tasks.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
