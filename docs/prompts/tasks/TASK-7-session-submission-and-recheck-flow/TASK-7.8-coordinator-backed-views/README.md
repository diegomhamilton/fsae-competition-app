# TASK#7.8 SPDD Prompt Run

Task: `7.8 Merge into 7.6 PRs w/ coordinator: Bind SessionSelectorView, ActiveTeamDashboardView, FullStageView, StepOverviewView, and TeamSwitchConfirmationView through coordinators to store-backed draft save/restore.`

Purpose: Bind existing SwiftUI views to coordinator-backed state without moving flow logic into views, and close the integration gap where the app does not yet use InspectionEventStore for draft save/restore.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: SessionSelectorView; ActiveTeamDashboardView; FullStageView; StepOverviewView; TeamSwitchConfirmationView; coordinators; InspectionEventStore integration
- Validation: Swift Testing for view helpers or coordinator state; manual smoke notes for navigation and draft restore; exclude stage submission wiring.
- Split trigger: Split if more than two view files and two coordinator files change together, unless this is the first integration PR linking coordinators/views to the store.

Expected PR title:

`TASK#7.8: Coordinator Backed Views`

Branch:

`codex/inspection-event-session-flow-7-8-coordinator-backed-views`

Common instructions:

- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Keep stage submission wiring out of the first coordinator/view/store draft integration PR.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
