# Structure Prompt

For this task:

Task: `6.3 Implement the test case list view from bundled JSON content, grouped by stage sections and ordered by display order.`

Define the implementation structure before editing code.

Include:

- Files to inspect first
- Files that may be added or edited
- View/component boundaries
- View helper test boundaries
- Preview fixture approach
- Expected compile state after the task
- Commit boundaries

Expected files to inspect:

- OpenSpec proposal, design, tasks, and specs
- `Design/Resources/InspectionEvent/*.json`
- `FullStageView.swift`
- `StageChecklistView.swift`
- `TestCaseView.swift`
- `StepOverviewView.swift`
- `DesignSystem.swift`
- Existing model, validation, and view-state tests

Expected edit scope:

- Add this prompt folder first.
- Add or refactor a sectioned test case list component.
- Add focused view helper tests if presentation logic is extracted.
- Keep `FullStageView` submission refactor for TASK#6.4.
- Avoid manual validation artifacts until TASK#6.7.

Recommended commit sequence:

- `Add TASK#6.3 prompt run`
- `Add test case list view`
- `Add test case list helpers` if helper tests are added separately

Return the proposed file tree and explain which files are view, helper, test, or prompt-only.
