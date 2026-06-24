# TASK#6.7 Manual Validation Checklist

Task: `6.7 Manually validate Garage, EV, Egress, and Rain stage content against Design/Resources/InspectionEvent/*.json.`

Build policy: user-run. Do not mark this task complete until actual app evidence is recorded.

Status: prepared for manual validation. Source review was performed against the bundled JSON and current stage/list code, but no app build, simulator run, screenshot, or VoiceOver pass has been observed for TASK#6.7.

Acceptance sources:

- `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`
- `Design/Resources/InspectionEvent/01_garage_inspection.json`
- `Design/Resources/InspectionEvent/04_ev_inspection.json`
- `Design/Resources/InspectionEvent/05_egress_test.json`
- `Design/Resources/InspectionEvent/06_rain_test.json`

## Prerequisites

- [x] Source review: TASK#6.1 stage content tests are present in `InspectionStageContentTests.swift`.
- [x] Source review: TASK#6.2 `InspectionContentService` loads six bundled JSON resources in display order.
- [x] Source review: TASK#6.3 `StageChecklistView` and `InspectionStageListViewState` group JSON-backed content by ordered section and test case.
- [ ] App evidence: TASK#6.4 `FullStageView` renders model-backed progress, blockers, and submit controls for bundled stage content.
- [ ] App evidence: TASK#6.5 energized EV badges are visible and have accessibility-equivalent safety information in the stage/test case UI.
- [ ] App evidence: TASK#6.6 stage/list strings and accessibility identifiers are present on actionable stage/list controls.

Prerequisite notes:

```text
OpenSpec `tasks.md` still lists TASK#6.4, TASK#6.5, TASK#6.6, and TASK#6.7 unchecked. Treat this checklist as ready-to-run validation until those implementation slices have observed app evidence.
```

## User-Run Signal

Command or app run used:

```text
[not run]
```

Environment:

```text
[not recorded]
```

Evidence links or attachments:

```text
[not recorded]
```

## Source Review Summary

Run these source-review checks before or alongside manual app validation:

- [x] Official stage order in JSON is Garage Inspection, Body Inspection, Chassis Inspection, EV Inspection, Egress Test, Rain Test.
- [x] Garage source has 1 section, 9 test cases, 9 steps, and 1 measurement step.
- [x] EV source has 8 sections, 119 test cases, 165 steps, 16 measurement steps, and 17 energized badged test cases.
- [x] Egress source has 1 section, 1 test case, 21 steps, and 4 measurement steps.
- [x] Rain source has 1 section, 1 energized badged test case, 22 steps, and 3 measurement steps.
- [x] Source review found no `requiresEvidence: true` fields in the four bundled JSON files. Evidence-gating app checks should be recorded only if current implementation derives evidence requirements from another reviewed policy source or if a later content update adds evidence metadata.

## Garage Inspection

Source: `Design/Resources/InspectionEvent/01_garage_inspection.json`
Expected JSON shape: stage order `1`, title `Garage Inspection`, section `Driver Equipment`, 9 cases `G1` through `G9`.

- [ ] Stage title matches JSON.
- [ ] Stage appears in official order.
- [ ] Section appears in `displayOrder`: `Driver Equipment`.
- [ ] Test cases appear in `displayOrder`: `G1 HELMETS`, `G2 BALACLAVA`, `G3 ARM RESTRAINTS`, `G4 DRIVERS' SUITS`, `G5 GLOVES`, `G6 SHOES`, `G7 SOCKS`, `G8 WET TIRES`, `G9 FIRE EXTINGUISHERS`.
- [ ] Step rows preserve content and step type; `G8 WET TIRES` is shown as a measurement step.
- [ ] Rule references are visible where expected.
- [ ] Progress updates from test case draft state.
- [ ] Submit-ready and blocked-submit states are understandable without color alone.
- [ ] Opening a test case from the stage preserves active team and stage context.

Observed result:

```text
[not run]
```

## EV Inspection

Source: `Design/Resources/InspectionEvent/04_ev_inspection.json`
Expected JSON shape: stage order `4`, title `EV Inspection`, 8 sections, 119 cases, 17 `CAUTION: ENERGIZED` cases.

- [ ] Stage title matches JSON.
- [ ] Sections appear in `displayOrder`:
  - `1` Personal Protective Equipment and External Checks / Start with accumulator container closed, cases `1-18`
  - `2` Accumulator Hand Cart, cases `19-23`
  - `3` Accumulator Charger, cases `24-32`
  - `4` Accumulator Internal Checks / Container Open, cases `33-46`
  - `5` Spare parts, case `47`
  - `6` Charging Procedure, cases `48-57`
  - `7` EV Mechanical Inspection, cases `58-70`
  - `8` TS Design and Components, cases `71-119`
- [ ] Test cases appear in `displayOrder` within each section.
- [ ] Rule references are visible where expected.
- [ ] Measurement rows are visible for cases including `EV25`, `EV49`, `EV50`, `EV54`, `EV76`, `EV80`, and energized cases `EV101` through `EV109` plus `EV112`.
- [ ] Energized dynamic test cases show `CAUTION: ENERGIZED`: `EV101` through `EV113`, plus `EV115`, `EV116`, `EV117`, and `EV118`.
- [ ] VoiceOver/accessibility text exposes the energized safety state.
- [ ] Non-energized neighboring EV cases do not show false-positive energized badges, including `EV99`, `EV100`, `EV114`, and `EV119`.
- [ ] Validation blockers are visible and correction routing is understandable.
- [ ] Blocked-submit correction can navigate to the first invalid EV test case or step when implementation supports it.

Observed result:

```text
[not run]
```

## Egress Test

Source: `Design/Resources/InspectionEvent/05_egress_test.json`
Expected JSON shape: stage order `5`, title `Egress Test`, section `Egress Procedure`, one case `EgressTest`, 21 steps.

- [ ] Stage title matches JSON.
- [ ] Section and test case appear in `displayOrder`: `Egress Procedure` -> `EGRESS TEST`.
- [ ] Step rows preserve the 21-step order and step types.
- [ ] Measurement steps show expected content and input affordance where available: step display orders `6`, `7`, `11`, and `14`.
- [ ] Valid measurement state contributes to progress.
- [ ] Invalid measurement state blocks submit where available.
- [ ] Validation summary identifies the blocking measurement step.
- [ ] If stopwatch support is unavailable in this slice, record that as a future TASK#10.9 gap rather than a TASK#6.7 failure.

Observed result:

```text
[not run]
```

## Rain Test

Source: `Design/Resources/InspectionEvent/06_rain_test.json`
Expected JSON shape: stage order `6`, title `Rain Test`, section `Rain Test Procedure`, one energized case `RainTest`, 22 steps.

- [ ] Stage title matches JSON.
- [ ] Section and test case appear in `displayOrder`: `Rain Test Procedure` -> `RAIN TEST`.
- [ ] Step rows preserve the 22-step order and step types.
- [ ] Rule references are visible where expected.
- [ ] Stage/test case visibly exposes the `CAUTION: ENERGIZED` badge from JSON.
- [ ] VoiceOver/accessibility text exposes the energized safety state.
- [ ] Measurement steps show expected content and input affordance where available: step display orders `17`, `19`, and `20`.
- [ ] Required evidence state is visible where available. Source review found no explicit evidence-required field in `06_rain_test.json`; only record a pass if app evidence shows a reviewed derived policy.
- [ ] Missing evidence blocks submit where available. Source review found no explicit evidence-required field in `06_rain_test.json`; only record a pass if app evidence shows a reviewed derived policy.
- [ ] Failed outcome without notes blocks submit where available.
- [ ] Validation summary identifies first invalid content.

Observed result:

```text
[not run]
```

## Feature Scenario Mapping

- Positive:
  - [ ] Stage opens from active team dashboard.
  - [ ] Test case opens from stage.
  - [ ] Valid stage can reach submit-ready state.
  - [ ] Ordered inspection stages match the `@inspection-data` scenario.
- Negative:
  - [ ] Missing required outcome blocks submit.
  - [ ] Failed step without notes blocks submit.
  - [ ] Invalid measurement blocks submit.
  - [ ] Missing required evidence blocks submit only if the running app has a reviewed evidence-required policy for the validated content.
- Edge:
  - [ ] Energized EV safety badge is visible and accessible.
  - [ ] Rain energized safety badge is visible and accessible.
  - [ ] Ordered stage content matches JSON even when sections or test cases vary in size.
  - [ ] Empty-step or zero-step source cases, if present in the rendered content, do not break row navigation or progress summaries.

Notes:

```text
[not recorded]
```

## Manual Evidence Required Before Completion

Record each item with the command/run signal, device or simulator, date, and reviewer initials.

- [ ] Screenshot or screen recording showing Garage JSON-backed stage content.
- [ ] Screenshot or screen recording showing EV section/test case ordering and energized badges.
- [ ] Screenshot or screen recording showing Egress measurement behavior.
- [ ] Screenshot or screen recording showing Rain energized badge and measurement behavior.
- [ ] Validation-blocking evidence for missing outcome, failed note, and invalid measurement.
- [ ] Evidence-required validation only if supported by the current reviewed content or policy.
- [ ] Accessibility evidence for stable identifiers or VoiceOver-equivalent energized safety text.

## Completion Decision

- [ ] Actual app evidence recorded.
- [ ] PR validation note updated with observed results.
- [ ] OpenSpec TASK#6.7 may be marked complete.
