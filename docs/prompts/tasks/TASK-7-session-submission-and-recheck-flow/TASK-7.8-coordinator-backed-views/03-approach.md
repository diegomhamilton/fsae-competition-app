# Approach Prompt

Given the requirements and entities for this task:

Task: `7.8 Merge into 7.6 PRs w/ coordinator: Bind SessionSelectorView, ActiveTeamDashboardView, FullStageView, StepOverviewView, and TeamSwitchConfirmationView to coordinator-backed state.`

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

Bind existing SwiftUI views through coordinators to store-backed draft save/restore without moving flow logic into views.

Validation expectation:

Swift Testing for view helpers or coordinator state; manual smoke notes for navigation and draft restore; exclude stage submission wiring.

Split trigger:

Split if more than two view files and two coordinator files change together, unless this is the first integration PR linking coordinators/views to the store.

Do not build automatically unless explicitly asked.
