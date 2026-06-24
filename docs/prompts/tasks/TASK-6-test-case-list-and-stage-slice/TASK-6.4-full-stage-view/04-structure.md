# Structure Prompt

For this task:

Task: `6.4 Refactor FullStageView to render real stage content, stage progress, validation blockers, and submit controls from model state.`

Define the implementation structure before editing code.

Include:

- Files to inspect first
- Files that may be added or edited
- View/helper boundaries
- Test boundaries
- Expected compile state after the task
- Commit boundaries

Expected files to inspect:

- OpenSpec proposal, design, tasks, and specs
- `FullStageView.swift`
- `StageChecklistView.swift`
- `TestCaseView.swift`
- `InspectionTestCaseViewState.swift`
- `InspectionValidationService.swift`
- `InspectionTestCaseModels.swift`
- `InspectionTestStepModels.swift`
- Existing unit tests for validation, test case view state, and coordinator behavior

Expected edit scope:

- Add this prompt folder first.
- Refactor `FullStageView` and focused helpers needed for stage progress/blockers.
- Add or update targeted unit tests for stage summaries or view-state helpers.
- Avoid session-store, submission snapshot, recheck, sticker, and manual validation work.

Recommended commit sequence:

- `Add TASK#6.4 prompt run`
- `Bind stage view to models`
- `Add stage summary tests` if helper tests are separate

Return the proposed file tree and explain which files are view, helper, test, or prompt-only.
