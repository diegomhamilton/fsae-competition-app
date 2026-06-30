# Requirements Prompt

You are helping with SPDD for this task:

Task: `7.1 Add failing coordinator tests for mock login completion, session selector routing, start session, resume session, stage selection, team switching, and restored context.`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible or reviewer-visible outcome
- Acceptance source, especially `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature` when relevant
- Required behavior
- Out of scope behavior
- Completion signal
- PR review risk if this task grows too broad

Keep this focused on what must be true, not how to build it.

Context:

- Macro-task: TASK#7 Session, Submission, and Recheck Flow
- Subtask: TASK#7.1
- Expected PR title: `TASK#7.1: Coordinator Tests`
- Feature branch: `codex/inspection-event-session-flow`
- Suggested task branch: `codex/inspection-event-session-flow-7-1-coordinator-tests`
- Operation summary: Add failing Swift Testing coverage for session-flow coordinator behavior before coordinator implementation, including store-backed draft save/restore.
- Likely files or targets: FSAEInspectionChecklistTests/*CoordinatorTests.swift; coordinator fixtures/helpers; store-backed draft fixtures
- Validation: Swift Testing failures first, then passing tests after coordinator/view store integration; stage submission wiring remains out of scope.
- Split trigger: Split if coordinator fixtures, store fixtures, or navigation helpers exceed one focused test file group.
- Common instructions:
- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Link coordinators/views to InspectionEventStore for draft save/restore before submission/recheck tasks.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
