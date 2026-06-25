# Structure Prompt

For this task:

Task: `6.5 Add energized dynamic test badge derivation for EV inspection steps and expose equivalent accessibility information.`

Define the implementation structure before editing code.

Include:

- Files to inspect first
- Files that may be added or edited
- Policy/helper boundaries
- Test boundaries
- Expected compile state after the task
- Commit boundaries

Expected files to inspect:

- OpenSpec proposal, design, tasks, and specs
- `Design/Resources/InspectionEvent/04_ev_inspection.json`
- `InspectionTestStepModels.swift`
- Stage/test case list view files from TASK#6.3
- `FullStageView.swift`
- Existing badge, accessibility, model, and view-state tests

Expected edit scope:

- Add this prompt folder first.
- Add or update model/content normalization helpers for energized badge derivation.
- Update existing badge rendering/view-state paths to expose visible and accessibility text.
- Add focused unit tests for derivation and accessibility-equivalent information.
- Avoid full accessibility identifier sweep and manual validation docs.

Recommended commit sequence:

- `Add TASK#6.5 prompt run`
- `Add energized badge policy`
- `Expose energized accessibility`

Return the proposed file tree and explain which files are policy, model, view helper, test, or prompt-only.
