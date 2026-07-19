```text
You are working in <repo-root>.

Goal:
Kill the surviving mutation tests in tools/mutation/results.csv, then update tools/mutation/README.md by replacing the "How We Fix It" prompt with a technical narrative of the actual fixes.

Context:
- Mutation harness: tools/mutation/run_mutants.sh
- Mutant patches: tools/mutation/patches/*.patch
- Latest evidence: mutation-results/20260630-220118-52976/summary.tsv
- Curated results: tools/mutation/results.csv
- Current survivors:
  - 0001-measurement-exclusive-bounds
  - 0002-measurement-no-input-trim
  - 0005-json-step-no-inherited-rule-reference
  - 0006-submission-allow-empty-stage-submission
  - 0007-submission-allow-duplicate-test-case-id
  - 0008-coordinator-open-invalid-stage
  - 0009-path-sanitization-keep-colon

Implementation constraints:
- Prefer focused Swift Testing unit tests over production refactors.
- Do not weaken production behavior to satisfy tests.
- Keep tests close to the owning behavior:
  - MeasurementValue and MeasurementRange behavior belongs in InspectionTestStepModelTests or InspectionValidationServiceTests.
  - Legacy JSON decoding belongs in TestCaseJSONPersistenceServiceTests or InspectionTestCaseModelTests, depending on the available fixture seam.
  - Submission invariants belong in SubmissionSnapshotServiceTests.
  - Route guards belong in InspectionCoordinatorTests or a coordinator-specific test that already owns InspectionExecutionCoordinator behavior.
  - Path sanitization belongs in TestCaseJSONPersistenceServiceTests.
- Preserve existing user changes and do not revert unrelated work.

Required fixes:
1. Add tests proving measurement minimum and maximum values are accepted.
2. Add tests proving whitespace-padded numeric measurement input is trimmed before parsing.
3. Add a decoding test proving a step with no explicit ruleReference inherits the parent test case rule reference.
4. Add a submission test proving empty stage submissions throw SubmissionSnapshotError.emptyStageSubmission.
5. Add a submission test proving duplicate draft testCase IDs throw SubmissionSnapshotError.duplicateTestCaseID.
6. Add a coordinator test proving unknown stage IDs are rejected and do not change the active route.
7. Add a persistence test proving colon characters in path-scoped IDs are sanitized to underscores.

Verification:
1. Run the focused test files or the full app test suite.
2. Run tools/mutation/run_mutants.sh.
3. Confirm every previous survivor is now killed.
4. Update tools/mutation/results.csv with the new statuses and review notes.
5. Replace this prompt in tools/mutation/README.md with a "How We Fix It" section that explains:
   - which tests were added,
   - which mutants each test kills,
   - why no production behavior needed to change unless a genuine bug was found,
   - the final mutation result summary.

README writing style:
- Keep the technical blog post/tutorial voice.
- Link each fix back to the domain invariant it protects.
- Include commands used for verification.
- Do not claim a mutant is killed unless the rerun proves it.
```