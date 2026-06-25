# Approach Prompt

Given the requirements and entities for this task:

Task: `10.1 Audit SessionSelectorView, ActiveTeamDashboardView, FullStageView, TestCaseView, StepOverviewView, and TeamSwitchConfirmationView for the minimum UX polish needed after Task 7 so a judge can complete a fully local, stored inspection without prototype copy, unclear navigation, or dead-end states.`

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

Audit stored local judge workflow screens for minimum UX polish after TASK#7.

Validation expectation:

Manual audit mapped to judge flow.

Split trigger:

Keep audit separate if it finds broad UI changes.

Do not build automatically unless explicitly asked.
