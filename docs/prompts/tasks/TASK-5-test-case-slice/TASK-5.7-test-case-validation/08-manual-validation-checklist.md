# TASK#5.7 Manual Validation Checklist

Status: Ready to run; not executed.

Task: `5.7 Manually validate the Test Case view with mock JSONs and record positive, negative, and edge cases from the .feature file.`

PR title: `TASK#5.7: Validate test case view`

Branch: `codex/task-5.7-test-case-validation`

## Current Base Assessment

This checklist was prepared from `origin/develop` at commit `47b0212`.

Actual manual validation was not performed because the active base contains the Test Step slice but does not yet contain the TASK#5.1-TASK#5.6 Test Case slice needed for this task:

- No `InspectionTestCase` model was found.
- No `TestCaseDraft` or composed test case draft state was found.
- No `InspectionValidationService` was found.
- No `MockInspectionTestCase` fixture loader or mock test case JSON fixtures were found.
- No Test Case view from TASK#5.6 was found.

Dependency: run this checklist against the branch that integrates TASK#5.6, or after TASK#5.6 is merged into `develop`.

Do not mark OpenSpec TASK#5.7 complete until the manual run records actual app evidence.

## Source Mapping

Primary acceptance source:

- `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`

Supporting OpenSpec requirements:

- `inspection-event-execution`: open test case, open test step, validation-gated submission.
- `inspection-event-json-content`: mock JSON test case view, ordered content, energized safety metadata.
- `inspection-event-accessibility-localization`: test case identifiers, VoiceOver safety badges, non-color status cues.
- `inspection-event-testing-strategy`: positive, negative, and edge cases mapped to feature scenarios.

## User-Owned Setup

Build policy: user-run. Do not run builds automatically unless explicitly asked.

User-run validation target:

```sh
open FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist.xcodeproj
```

Recommended manual run context after TASK#5.6 is integrated:

- Launch the app in the iOS simulator or device selected by the user.
- Navigate to a mock Test Case view from the stage/test case route provided by TASK#5.6.
- Use mock JSON cases that cover one step, multiple ordered steps, measurement steps, required evidence, failed notes, and energized badges.
- Record simulator/device, branch SHA, fixture names, and screenshots or notes for each case below.

## Evidence Fields

For each checklist item, capture:

- Result: `Pass`, `Fail`, or `Blocked`
- Branch and commit SHA
- Fixture name
- Device or simulator
- Steps performed
- Observed behavior
- Screenshot or recording reference, if available
- Notes and follow-up issue, if any

## Positive Cases

### P1 Completed Test Case

Feature mapping:

- `@US-002 @FL-002`
- Rule: `A stage can be submitted only after required outcomes and notes are valid`
- Scenario: `Submit a completed stage`

Fixture need:

- A test case with every required step resolved.
- Include at least one passing outcome and no validation blockers.

Manual steps:

1. Open the completed mock test case.
2. Confirm the test case title, item ID, rule reference, and progress summary are visible.
3. Confirm each ordered step row shows an accepted outcome.
4. Confirm the validation summary reports no blockers.
5. Return to the parent stage and confirm the parent state reflects the completed test case.

Expected result:

- The test case appears complete.
- No missing outcome, note, measurement, or evidence blocker is shown.
- The parent stage/test case list receives the completed status.

Evidence:

- Result:
- Fixture:
- Observed behavior:
- Notes:

### P2 Valid Measurement

Feature mapping:

- `@US-003 @FL-003`
- Rule: `Measurement values are validated before they affect stage completion`
- Scenario: `Record a valid measurement`

Fixture need:

- A measurement step equivalent to `Egress time`.
- Allowed range: `0.00` to `4.99` seconds.

Manual steps:

1. Open the measurement test case.
2. Open or focus the measurement step.
3. Enter `4.38`.
4. Save or return to the test case view.
5. Confirm the measurement is visible in the test case row or summary.

Expected result:

- `4.38 s` is saved as draft data.
- The step no longer appears incomplete.
- No measurement validation blocker is shown.

Evidence:

- Result:
- Fixture:
- Observed behavior:
- Notes:

### P3 Required Evidence Present

Feature mapping:

- `@US-004 @FL-004`
- Rule: `Evidence requirements gate submission when proof is required`
- Scenario: `Attach evidence metadata to a step`

Fixture need:

- A required-evidence step equivalent to `RML flashing`.

Manual steps:

1. Open the evidence-required test case.
2. Add attachment metadata named `rml-visible-photo`.
3. Return to the test case view.
4. Confirm the attachment metadata is visible.
5. Confirm the validation summary no longer reports missing evidence for that step.

Expected result:

- Evidence metadata is visible on the test case/step.
- The required evidence blocker clears.
- The UI does not require real camera or file storage for this slice.

Evidence:

- Result:
- Fixture:
- Observed behavior:
- Notes:

## Negative Cases

### N1 Missing Required Outcome

Feature mapping:

- `@US-002 @FL-002`
- Scenario: `Block submission when a required outcome is missing`

Fixture need:

- A test case containing required step `RT-08` or equivalent with outcome `Pending`/unset.

Manual steps:

1. Open the missing-outcome mock test case.
2. Confirm the required step appears without a selected outcome.
3. Attempt the task's available done/submit/readiness action.
4. Use the validation summary to navigate to the invalid step, if available.

Expected result:

- The test case is not considered complete.
- The validation summary identifies the missing required outcome and the affected step.
- Navigation to the first invalid step works when implemented by TASK#5.6.

Evidence:

- Result:
- Fixture:
- Observed behavior:
- Notes:

### N2 Failed Step Without Notes

Feature mapping:

- `@US-002 @FL-002`
- Scenario: `Require notes for a failed step when policy requires them`

Fixture need:

- A failed step equivalent to `RML flashing` with empty notes.
- Failed outcomes require inspector notes.

Manual steps:

1. Open the failed-without-notes mock test case.
2. Confirm the failed step is visible with no notes.
3. Attempt the task's available done/submit/readiness action.
4. Add notes and confirm the blocker clears.

Expected result:

- The validation summary reports that notes are required.
- The failed step row has a non-color status cue for the blocker.
- Adding notes clears the failed-note blocker while preserving the failed outcome.

Evidence:

- Result:
- Fixture:
- Observed behavior:
- Notes:

### N3 Invalid Measurement

Feature mapping:

- `@US-003 @FL-003`
- Scenario Outline: `Reject invalid measurement values`

Fixture need:

- A measurement step equivalent to `Egress time`.
- Allowed range: `0.00` to `4.99` seconds.

Manual steps:

1. Enter and save a valid prior value, such as `4.38`.
2. Try invalid value `fast`.
3. Try invalid value `4.999`.
4. Try invalid value `5.40`.
5. Return to the test case view after each attempt.

Expected result:

- `fast` is rejected as non-numeric.
- `4.999` is rejected for precision.
- `5.40` is rejected as outside range.
- The previous valid measurement remains unchanged.
- The validation message is readable and not color-only.

Evidence:

- Result:
- Fixture:
- Observed behavior:
- Notes:

### N4 Required Evidence Missing

Feature mapping:

- `@US-004 @FL-004`
- Scenario: `Block stage submission when required evidence is missing`

Fixture need:

- A required-evidence test case equivalent to `RML flashing` with no attachment metadata.

Manual steps:

1. Open the required-evidence-missing mock test case.
2. Confirm no attachment metadata is present.
3. Attempt the task's available done/submit/readiness action.
4. Confirm the validation summary identifies missing evidence.

Expected result:

- Missing required evidence blocks completion/readiness.
- The validation summary identifies the affected step.
- The evidence control has a stable accessibility identifier where available.

Evidence:

- Result:
- Fixture:
- Observed behavior:
- Notes:

## Edge Cases

### E1 Ordered Step Display

Feature mapping:

- `@inspection-data`
- Scenario: `View the ordered inspection stages`
- Related OpenSpec JSON content scenario: decode stage structure with ordered test cases and test steps.

Fixture need:

- A multi-step test case with intentionally non-alphabetical step titles and explicit `displayOrder`.

Manual steps:

1. Open the multi-step mock test case.
2. Compare visible row order against fixture `displayOrder`.
3. Navigate into a later step and back.
4. Confirm the order remains stable and the edited row state persists.

Expected result:

- Steps render by `displayOrder`, not fixture file order accidents, title, or ID.
- Navigation does not reorder rows.
- Edited draft values return to the correct step row.

Evidence:

- Result:
- Fixture:
- Observed behavior:
- Notes:

### E2 Energized Badge Accessibility

Feature mapping:

- `@inspection-data`
- Scenario: `Highlight energized dynamic test steps`
- Accessibility spec: `VoiceOver understands safety badges`

Fixture need:

- An EV or Rain Test case with badge `CAUTION: ENERGIZED` or a derived energized dynamic test indicator.

Manual steps:

1. Open the energized mock test case.
2. Confirm the safety badge is visible.
3. Confirm the badge includes text, not color alone.
4. With VoiceOver or Accessibility Inspector, confirm the safety state is announced as meaningful text.
5. Confirm the energized badge remains associated with the correct step/test case after navigation.

Expected result:

- The badge visibly reads `CAUTION: ENERGIZED`.
- VoiceOver announces equivalent safety information.
- The safety state is not conveyed by color alone.

Evidence:

- Result:
- Fixture:
- Observed behavior:
- Notes:

### E3 Evidence Removal Reopens Blocker

Feature mapping:

- `@US-004 @FL-004`
- Scenario: `Removing required evidence makes the step invalid again`

Fixture need:

- A required-evidence test case with attachment metadata already present.

Manual steps:

1. Open the evidence-present mock test case.
2. Remove attachment metadata `rml-visible-photo`.
3. Return to the validation summary.
4. Re-add the same metadata.

Expected result:

- Removing evidence makes the evidence requirement unsatisfied.
- The test case cannot be marked complete until evidence is restored.
- Re-adding evidence clears the blocker.

Evidence:

- Result:
- Fixture:
- Observed behavior:
- Notes:

## Completion Rule

TASK#5.7 is complete only when actual manual validation evidence is added to this checklist or the PR description and the results are mapped to the `.feature` scenarios above.

Until then, keep OpenSpec task `5.7` unchecked.

