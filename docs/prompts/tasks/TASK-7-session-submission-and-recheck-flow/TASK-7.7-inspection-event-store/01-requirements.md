# Requirements Prompt

You are helping with SPDD for this task:

Task: `7.7 Implement InspectionEventStore as an actor-isolated event/session source of truth with scoped queries by event, team, session, user access, and the JSON file persistence service.`

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
- Subtask: TASK#7.7
- Expected PR title: `TASK#7.7: Inspection Event Store`
- Feature branch: `codex/inspection-event-session-flow`
- Suggested task branch: `codex/inspection-event-session-flow-7-7-inspection-event-store`
- Operation summary: Verify or implement actor-isolated InspectionEventStore with scoped event/team/session/user queries backed by persistence.
- Likely files or targets: InspectionEventStore; query models; store tests
- Validation: Swift Testing for scoped queries, access isolation, async mutation behavior, and explicit success events if success must be queried outside signpost intervals.
- Split trigger: Split from coordinators if store APIs are still changing.
- Common instructions:
- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Treat successful signposts as intervals unless explicit success events are added.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
