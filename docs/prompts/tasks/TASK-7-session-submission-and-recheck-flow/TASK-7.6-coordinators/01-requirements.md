# Requirements Prompt

You are helping with SPDD for this task:

Task: `7.6 Break each coordinator into a different task PR: Implement AppCoordinator, InspectionEventCoordinator, SessionSelectionCoordinator, and InspectionExecutionCoordinator.`

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
- Subtask: TASK#7.6
- Expected PR title: `TASK#7.6: Coordinators`
- Feature branch: `codex/inspection-event-session-flow`
- Suggested task branch: `codex/inspection-event-session-flow-7-6-coordinators`
- Operation summary: Implement coordinators as separately reviewable task PRs or task branches.
- Likely files or targets: AppCoordinator; InspectionEventCoordinator; SessionSelectionCoordinator; InspectionExecutionCoordinator; tests
- Validation: Swift Testing coordinator route and intent checks.
- Split trigger: Always split if all four coordinators push the PR over 10 files or one reviewer cannot inspect flow safely.
- Common instructions:
- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
