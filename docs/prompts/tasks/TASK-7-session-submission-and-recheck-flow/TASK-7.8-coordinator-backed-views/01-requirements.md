# Requirements Prompt

You are helping with SPDD for this task:

Task: `7.8 Merge into 7.6 PRs w/ coordinator: Bind SessionSelectorView, ActiveTeamDashboardView, FullStageView, StepOverviewView, and TeamSwitchConfirmationView to coordinator-backed state.`

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
- Subtask: TASK#7.8
- Expected PR title: `TASK#7.8: Coordinator Backed Views`
- Feature branch: `codex/inspection-event-session-flow`
- Suggested task branch: `codex/inspection-event-session-flow-7-8-coordinator-backed-views`
- Operation summary: Bind existing SwiftUI views through coordinators to store-backed draft save/restore without moving flow logic into views.
- Likely files or targets: SessionSelectorView; ActiveTeamDashboardView; FullStageView; StepOverviewView; TeamSwitchConfirmationView; coordinators; InspectionEventStore integration
- Validation: Swift Testing for view helpers or coordinator state; manual smoke notes for navigation and draft restore; exclude stage submission wiring.
- Split trigger: Split if more than two view files and two coordinator files change together, unless this is the first integration PR linking coordinators/views to the store.
- Common instructions:
- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Keep stage submission wiring out of the first coordinator/view/store draft integration PR.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
