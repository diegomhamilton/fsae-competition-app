# Structure Prompt

For this task:

Task: `6.7 Manually validate Garage, EV, Egress, and Rain stage content against Design/Resources/InspectionEvent/*.json.`

Define the documentation and validation structure.

Include:

- Files to inspect first
- Files that may be added or edited
- Checklist sections
- PR validation note sections
- Evidence fields
- Completion rules
- Commit boundaries

Expected files to inspect:

- OpenSpec proposal, design, tasks, and specs
- `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`
- `Design/Resources/InspectionEvent/01_garage_inspection.json`
- `Design/Resources/InspectionEvent/04_ev_inspection.json`
- `Design/Resources/InspectionEvent/05_egress_test.json`
- `Design/Resources/InspectionEvent/06_rain_test.json`
- Stage/list views, `FullStageView`, accessibility ID helpers, and TASK#6.1 through TASK#6.6 outputs

Expected edit scope:

- Add this prompt folder first.
- Add `08-manual-validation-checklist.md`.
- Add `09-pr-validation-note-draft.md`.
- Fill observed results only if actual app evidence exists.
- Avoid implementation edits unless the user explicitly broadens scope.
- Avoid OpenSpec checkbox updates unless TASK#6.7 is actually complete with evidence.

Recommended commit sequence:

- `Add TASK#6.7 prompt run`
- `Add stage validation checklist`
- `Draft stage validation notes`

Return the proposed file tree and explain which files are prompt setup, validation artifacts, or later evidence updates.
