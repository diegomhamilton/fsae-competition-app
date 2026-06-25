# Entities Prompt

For this task:

Task: `7.8 Merge into 7.6 PRs w/ coordinator: Bind SessionSelectorView, ActiveTeamDashboardView, FullStageView, StepOverviewView, and TeamSwitchConfirmationView to coordinator-backed state.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- SessionSelectorView
- ActiveTeamDashboardView
- FullStageView
- StepOverviewView
- TeamSwitchConfirmationView
- coordinators

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#7 Session, Submission, and Recheck Flow
- Subtask: TASK#7.8
- Expected PR title: `TASK#7.8: Coordinator Backed Views`
- Feature branch: `codex/inspection-event-session-flow`
- Suggested task branch: `codex/inspection-event-session-flow-7-8-coordinator-backed-views`
- Operation summary: Bind existing SwiftUI views to coordinator-backed state without moving flow logic into views.
- Likely files or targets: SessionSelectorView; ActiveTeamDashboardView; FullStageView; StepOverviewView; TeamSwitchConfirmationView; coordinators
- Validation: Swift Testing for view helpers or coordinator state; manual smoke notes for navigation.
- Split trigger: Split if more than two view files and two coordinator files change together.
- Common instructions:
- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
