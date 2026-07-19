# Ranking Mutation Survivors in the FSAE Inspection App

This folder contains a small, patch-based mutation testing harness for the FSAE Inspection Checklist app. The goal is not to chase a vanity mutation score. The goal is to make test gaps visible, rank them by the kind of user-facing damage they could allow, and turn the highest-value survivors into focused tests.

The run captured in `mutation-results/20260630-220118-52976` tested nine hand-written mutants against the macOS Swift Testing suite. Two mutants were killed by existing tests. Seven survived, which means those defects could be introduced without the current unit suite noticing.

## Tutorial: What This Folder Contains

Start with three files:

- `patches/`: one patch per mutant. Each patch changes one production behavior in a way that should be wrong.
- `run_mutants.sh`: applies each patch, runs the app test suite, records whether the mutant was killed, and reverts the patch.
- `results.csv`: the human review layer with a note about what each result means.

Run the harness from the repository root:

```bash
tools/mutation/run_mutants.sh
```

By default, the script:

1. Finds all `*.patch` files in `tools/mutation/patches`.
2. Creates a result directory under `mutation-results/<timestamp>-<pid>`.
3. Applies one mutant patch at a time with `git apply`.
4. Runs:

```bash
xcodebuild test \
  -project FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist.xcodeproj \
  -scheme FSAEInspectionChecklist \
  -destination platform=macOS \
  -enableCodeCoverage YES \
  -derivedDataPath /tmp/fsae-mutation-derived-data \
  -resultBundlePath <mutant-result>/TestResult.xcresult \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=
```

5. Marks the mutant as `killed` when tests fail, or `survived` when tests pass.
6. Reverts the patch before moving to the next mutant.

The generated `summary.tsv` is the raw scoreboard. `results.csv` is the curated reading of that scoreboard.

## The Ranking Logic

Mutation ranking starts after the test result is known. A killed mutant proves the suite already protects that behavior. A survived mutant is a candidate test gap, but not every gap deserves equal attention.

We rank survivors with four questions:

1. **User impact:** Could this corrupt inspection evidence, allow an invalid submission, route a judge to invalid state, or create unsafe compliance output?
2. **Invariant strength:** Is the behavior a domain rule that should never be optional, such as immutable submissions, duplicate IDs, route guards, or measurement validity?
3. **Boundary sensitivity:** Is the mutation sitting on an edge case that production data or judge input can naturally hit, such as exact min/max measurements or whitespace in typed input?
4. **Detection cost:** Can one small unit test kill the mutant without broad refactoring, fixture churn, or brittle UI automation?

That gives us this priority order:

| Rank | Mutant | Status | Why it ranks here |
| --- | --- | --- | --- |
| 1 | `0006-submission-allow-empty-stage-submission` | Survived | Empty stage submissions are invalid records. This is a submission integrity invariant and should fail fast. |
| 2 | `0007-submission-allow-duplicate-test-case-id` | Survived | Duplicate test case IDs can overwrite or misrepresent submitted inspection data. This threatens auditability. |
| 3 | `0008-coordinator-open-invalid-stage` | Survived | Invalid route acceptance can put the session coordinator into a state the UI should never expose. |
| 4 | `0009-path-sanitization-keep-colon` | Survived | Persistence path sanitization protects local storage layout across event, team, session, and submission identifiers. |
| 5 | `0001-measurement-exclusive-bounds` | Survived | Exact minimum and maximum measurements should be valid when the rule says the range is inclusive. |
| 6 | `0002-measurement-no-input-trim` | Survived | Whitespace-padded numeric input is common in typed entry and should not become a false validation failure. |
| 7 | `0005-json-step-no-inherited-rule-reference` | Survived | Legacy JSON decoding should preserve inherited rule references when a step omits its own rule. |
| Covered | `0003-measurement-skip-precision-validation` | Killed | Existing measurement validation tests already reject over-precision values. |
| Covered | `0004-rule-refs-include-duplicates-and-empty` | Killed | Existing model/view-state tests already catch duplicate and empty rule references. |

This order intentionally prefers submission and persistence invariants over display polish. A duplicated rule chip is annoying. A submitted snapshot that silently accepts impossible input is much harder to unwind.

## What We Tested

Each mutant targeted one behavioral contract:

### Measurement Bounds

`0001-measurement-exclusive-bounds` changed `MeasurementRange.contains(_:)` from inclusive bounds to exclusive bounds. The tests still passed, so current coverage checks inside and outside the range, but not values exactly equal to `minimum` or `maximum`.

### Measurement Input Normalization

`0002-measurement-no-input-trim` removed whitespace trimming before parsing `MeasurementValue`. The tests still passed, so the suite does not prove that `" 4.38 "` is accepted the same way as `"4.38"`.

### Measurement Precision

`0003-measurement-skip-precision-validation` removed the maximum fraction digit check. This mutant was killed by:

- `InspectionValidationServiceTests/us003ValidatesMeasurementInputThroughMeasurementValue()`
- `InspectionTestStepModelTests/us003MeasurementValueAcceptsValidValuesAndRejectsInvalidValues()`

Those tests already assert that `4.999` fails when only two fraction digits are allowed.

### Rule Reference Aggregation

`0004-rule-refs-include-duplicates-and-empty` removed empty filtering and de-duplication from `InspectionTestCase.allRuleReferences`. This mutant was killed by:

- `InspectionStageListViewStateTests/inspectionDataStageListRowsPreserveExplicitSafetyBadgesAndRules()`
- `TestCaseCoordinatorTests/openTestCaseFromStageSelectsParentDraft()`

The existing suite protects the public rule-reference list used by stage rows and coordinator-selected drafts.

### Legacy JSON Rule Inheritance

`0005-json-step-no-inherited-rule-reference` stopped falling back to the parent test case rule when a decoded step has no explicit `ruleReference`. The tests passed, which exposes a fixture gap around legacy or compact JSON content.

### Submission Integrity

`0006-submission-allow-empty-stage-submission` bypassed the guard that rejects an empty draft list. The tests passed, so `SubmissionSnapshotService` currently proves happy-path creation and immutability, but not the empty-stage rejection path.

`0007-submission-allow-duplicate-test-case-id` bypassed duplicate draft detection. The tests passed, so submission snapshots can be tested more directly for duplicate test case identity rejection.

### Coordinator Route Guards

`0008-coordinator-open-invalid-stage` bypassed `InspectionExecutionCoordinator.openStage(id:)` validation. The tests passed, so the coordinator suite opens known stages but does not assert that unknown stages return `false` and leave the current route unchanged.

### Persistence Path Sanitization

`0009-path-sanitization-keep-colon` stopped replacing `:` with `_` when building persistence paths. The tests passed, so current persistence tests prove scoped folder placement but do not pin the exact sanitization behavior for colon-containing identifiers.

## The Failures This Exposed

The survived mutants exposed seven missing negative or boundary tests:

| Mutant | Exposed failure | Test to add |
| --- | --- | --- |
| `0001` | Inclusive measurement limits are not protected. | Assert `minimum` and `maximum` are accepted by `MeasurementValue`. |
| `0002` | Whitespace-normalized numeric input is not protected. | Assert padded input parses and stores the trimmed decimal. |
| `0005` | Legacy decoded steps may lose inherited rule references. | Decode a case where a step omits `ruleReference` and assert parent fallback. |
| `0006` | Empty stage submissions may be accepted. | Call `createSubmittedStageSnapshot` with no drafts and expect `emptyStageSubmission`. |
| `0007` | Duplicate draft IDs may be accepted. | Submit two drafts with the same ID and expect `duplicateTestCaseID`. |
| `0008` | Unknown stage IDs may be routable. | Call `openStage(id:)` with an unknown ID and assert it returns `false` without changing route. |
| `0009` | Colon-containing IDs may leak into path segments. | Use an ID containing `:` and assert the generated storage path replaces it with `_`. |

The killed mutants also tell us what not to over-fix:

- Precision validation already has direct model and service coverage.
- Rule-reference aggregation already has coverage through both model-facing and view-state-facing behavior.

## How We Fix It

The fix pass kept the production code unchanged. Each survivor represented a missing assertion around behavior the app already implemented correctly, so the safest response was to add focused Swift Testing coverage at the owner of each invariant.

First, `InspectionTestStepModelTests` now pins measurement parsing at the boundary and normalization layers:

- `us003MeasurementValueAcceptsInclusiveBounds()` protects the domain rule that a stated measurement range is inclusive. It kills `0001-measurement-exclusive-bounds` by proving both `minimum` and `maximum` values are valid.
- `us003MeasurementValueTrimsPaddedNumericInput()` protects the judge input normalization rule. It kills `0002-measurement-no-input-trim` by proving whitespace-padded numeric entry parses to the same stored decimal value.

Second, `InspectionTestCaseModelTests` now covers compact or legacy JSON content where a step omits its own rule reference:

- `us002DecodedTestStepsInheritParentRuleReferenceWhenOmitted()` decodes a test case with `ruleReferences: ["RAIN.1"]` and a step with no `ruleReference`. It kills `0005-json-step-no-inherited-rule-reference` by proving the decoded step inherits the parent rule and `allRuleReferences` still exposes the rule once.

Third, `SubmissionSnapshotServiceTests` now exercises the submission integrity guards directly:

- `rejectsEmptyStageSubmissions()` kills `0006-submission-allow-empty-stage-submission` by proving an empty draft list throws `SubmissionSnapshotError.emptyStageSubmission`.
- `rejectsDuplicateDraftTestCaseIDs()` kills `0007-submission-allow-duplicate-test-case-id` by proving duplicate draft IDs throw `SubmissionSnapshotError.duplicateTestCaseID("garage-main")` before snapshots are written.

Fourth, `InspectionCoordinatorTests` now protects the route guard for execution flow:

- `executionCoordinatorRejectsUnknownStageRoutes()` kills `0008-coordinator-open-invalid-stage` by opening a known stage, attempting an unknown stage, and asserting the call returns `false` without changing the active route or active stage.

Finally, `TestCaseJSONPersistenceServiceTests` now pins path-scoped ID sanitization:

- `sanitizesColonCharactersInPathScopedIdentifiers()` kills `0009-path-sanitization-keep-colon` by proving event, team, session, stage, and test case IDs containing `:` are mapped to `_` in generated draft paths.

The two mutants that were already killed stayed covered:

- `0003-measurement-skip-precision-validation` is still caught by existing precision validation tests.
- `0004-rule-refs-include-duplicates-and-empty` is still caught by existing model and view-state rule aggregation assertions.

Verification used a focused test pass first:

```bash
xcodebuild test \
  -project FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist.xcodeproj \
  -scheme FSAEInspectionChecklist \
  -destination platform=macOS \
  -derivedDataPath /tmp/fsae-focused-derived-data \
  -only-testing:FSAEInspectionChecklistTests/InspectionTestStepModelTests \
  -only-testing:FSAEInspectionChecklistTests/InspectionTestCaseModelTests \
  -only-testing:FSAEInspectionChecklistTests/TestCaseJSONPersistenceServiceTests \
  -only-testing:FSAEInspectionChecklistTests/SubmissionSnapshotServiceTests \
  -only-testing:FSAEInspectionChecklistTests/InspectionCoordinatorTests \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=
```

That pass succeeded. Then the full mutation harness was rerun:

```bash
bash tools/mutation/run_mutants.sh
```

The new run is in `mutation-results/20260630-233047-87664`. Its `summary.tsv` shows all nine mutants killed:

| Mutant | Status | Exit code |
| --- | --- | --- |
| `0001-measurement-exclusive-bounds` | killed | 65 |
| `0002-measurement-no-input-trim` | killed | 65 |
| `0003-measurement-skip-precision-validation` | killed | 65 |
| `0004-rule-refs-include-duplicates-and-empty` | killed | 65 |
| `0005-json-step-no-inherited-rule-reference` | killed | 65 |
| `0006-submission-allow-empty-stage-submission` | killed | 65 |
| `0007-submission-allow-duplicate-test-case-id` | killed | 65 |
| `0008-coordinator-open-invalid-stage` | killed | 65 |
| `0009-path-sanitization-keep-colon` | killed | 65 |

The final result is 9 killed, 0 survived. More importantly, the suite now protects the domain invariants that matter for inspection evidence: inclusive measurements, normalized judge input, inherited rule context, immutable submission shape, guarded routes, and storage-safe identifiers.
