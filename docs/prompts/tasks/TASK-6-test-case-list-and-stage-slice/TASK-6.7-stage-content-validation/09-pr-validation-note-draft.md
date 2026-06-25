# TASK#6.7 PR Validation Note Draft

## Summary

Prepared manual validation coverage for JSON-backed Garage, EV, Egress, and Rain stage content. This is a ready-to-run validation package; manual app validation is not complete until observed app evidence is recorded in the checklist.

## Scope

- Validate stage titles, section ordering, test case ordering, step content, rule references, and badges against bundled JSON.
- Validate stage progress, blockers, submit controls, and blocked-submit correction cues.
- Validate energized EV and Rain badge visibility and accessibility-equivalent safety text.
- Validate measurement behavior for Garage wet tires, EV measurement cases, Egress timing steps, and Rain measurement steps where current UI supports input and validation.
- Map checks to positive, negative, and edge scenarios from `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`.
- Document evidence-required behavior only where current app evidence shows a reviewed content or policy source, because the four bundled JSON files reviewed for this task do not contain explicit `requiresEvidence: true` fields.

## Notes

- Build and manual app validation are user-run for this task.
- Do not mark TASK#6.7 complete until observed app evidence replaces `[not run]` checklist entries in `08-manual-validation-checklist.md`.
- OpenSpec `tasks.md` still lists TASK#6.4, TASK#6.5, TASK#6.6, and TASK#6.7 unchecked at the time this validation package was prepared.
- Current branch during preparation was not relied on for completion; expected task branch is `codex/task-6.7-stage-content-validation`.
- Static source review re-run found:
  - Garage: `displayOrder: 1`, 1 section, 9 cases, 9 steps, 1 measurement step.
  - EV: `displayOrder: 4`, 8 sections, 119 cases, 165 steps, 16 measurement steps, 17 `CAUTION: ENERGIZED` cases.
  - Egress: `displayOrder: 5`, 1 section, 1 case, 21 steps, 4 measurement steps.
  - Rain: `displayOrder: 6`, 1 section, 1 energized case, 22 steps, 3 measurement steps.
  - No explicit `requiresEvidence: true` fields were present in the reviewed bundled JSON files.
- If prerequisites from TASK#6.1 through TASK#6.6 are missing in the running app, keep this as a ready-to-run validation package and document blockers.

## Validation

- `[static]` Read OpenSpec proposal, design, tasks, and capability specs for the inspection event plan.
- `[static]` Read `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`.
- `[static]` Inspected `Design/Resources/InspectionEvent/01_garage_inspection.json`, `04_ev_inspection.json`, `05_egress_test.json`, and `06_rain_test.json` with `jq` and `rg`.
- `[static]` Inspected current stage/list implementation files for source-review context only; no implementation files were edited.
- `[pending:user-run]` Run the checklist in `docs/prompts/tasks/TASK-6-test-case-list-and-stage-slice/TASK-6.7-stage-content-validation/08-manual-validation-checklist.md`.
- `[pending]` Record the user-run command or app build used.
- `[pending]` Record observed results for Garage Inspection.
- `[pending]` Record observed results for EV Inspection.
- `[pending]` Record observed results for Egress Test.
- `[pending]` Record observed results for Rain Test.
- `[pending]` Record stable accessibility identifier or VoiceOver-equivalent evidence for energized safety states.
