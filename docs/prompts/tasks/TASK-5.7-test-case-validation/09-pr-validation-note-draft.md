# TASK#5.7 PR Validation Note Draft

Use this draft in the PR description after the user performs the manual app validation.

## Summary

Prepared manual validation coverage for the Test Case view using mock JSON scenarios mapped to `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`.

## Scope

- Covers positive cases for completed test cases, valid measurements, and required evidence present.
- Covers negative cases for missing required outcomes, failed steps without required notes, invalid measurements, and missing required evidence.
- Covers edge cases for ordered step display, energized safety badge accessibility, and evidence removal reopening validation blockers.
- Keeps validation user-run under the no-build policy.

## Notes

- Actual manual validation is not complete until run against a branch containing TASK#5.6's Test Case view.
- On `origin/develop` at `47b0212`, the Test Case view, `InspectionTestCase`, test case mock JSON fixtures, and `InspectionValidationService` are not present.
- Do not mark OpenSpec TASK#5.7 complete unless this PR records actual validation evidence.

## Validation

User-run build/inspection:

- `[pending]` Open `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist.xcodeproj`
- `[pending]` Launch the app on the user's chosen simulator/device.
- `[pending]` Navigate to the Test Case view from the TASK#5.6-integrated branch.
- `[pending]` Run the checklist in `docs/prompts/tasks/TASK-5.7-test-case-validation/08-manual-validation-checklist.md`.

Manual validation matrix:

| Case | Type | Feature mapping | Status | Evidence |
| --- | --- | --- | --- | --- |
| Completed test case | Positive | `Submit a completed stage` | Pending user-run validation | |
| Valid measurement `4.38` | Positive | `Record a valid measurement` | Pending user-run validation | |
| Required evidence present | Positive | `Attach evidence metadata to a step` | Pending user-run validation | |
| Missing required outcome | Negative | `Block submission when a required outcome is missing` | Pending user-run validation | |
| Failed step without notes | Negative | `Require notes for a failed step when policy requires them` | Pending user-run validation | |
| Invalid measurement `fast` / `4.999` / `5.40` | Negative | `Reject invalid measurement values` | Pending user-run validation | |
| Required evidence missing | Negative | `Block stage submission when required evidence is missing` | Pending user-run validation | |
| Ordered step display | Edge | JSON content ordered structure / ordered inspection data | Pending user-run validation | |
| Energized badge accessibility | Edge | `Highlight energized dynamic test steps` | Pending user-run validation | |
| Evidence removal reopens blocker | Edge | `Removing required evidence makes the step invalid again` | Pending user-run validation | |

Validation result summary:

- Result:
- Branch/SHA:
- Simulator/device:
- Fixture names:
- Screenshots/recordings:
- Follow-up issues:

