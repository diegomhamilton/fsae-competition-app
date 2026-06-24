# Structure Prompt

For this task:

Task: `6.6 Add structured Strings enums and stable accessibility identifiers to the stage and test case list files.`

Define the implementation structure before editing code.

Include:

- Files to inspect first
- Files that may be added or edited
- Strings enum boundaries
- Accessibility identifier helper boundaries
- Test boundaries
- Expected compile state after the task
- Commit boundaries

Expected files to inspect:

- OpenSpec proposal, design, tasks, and accessibility/localization spec
- `FullStageView.swift`
- Stage/test case list view files from TASK#6.3
- `TestCaseView.swift`
- `InspectionTestStepModels.swift` or existing accessibility helper file
- Existing accessibility identifier tests
- Existing SwiftUI files that already use structured `Strings` enums

Expected edit scope:

- Add this prompt folder first.
- Update stage/list UI files and focused identifier helpers/tests.
- Avoid adding dedicated UI automation targets or snapshot test dependencies.
- Avoid changing content loading, validation rules, or manual validation docs.

Recommended commit sequence:

- `Add TASK#6.6 prompt run`
- `Structure stage view strings`
- `Add stage accessibility IDs`

Return the proposed file tree and explain which files are strings, accessibility, test, or prompt-only.
