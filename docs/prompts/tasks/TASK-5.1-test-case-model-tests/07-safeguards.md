# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `5.1 Add failing unit tests for InspectionTestCase, ordered steps, rule references, draft aggregation, blocker counts, and test case progress.`

Plan: `<paste operations>`

Review for:

- Scope creep beyond failing unit tests
- Accidental production model, service, coordinator, fixture, or view implementation
- Missing failing tests for ordered steps
- Missing failing tests for rule references
- Missing failing tests for draft aggregation
- Missing failing tests for blocker counts
- Missing failing tests for test case progress
- Missing coverage for missing outcome, failed notes, invalid measurement, and missing evidence
- Missing mapping to `.feature` scenarios for open test case, validation blocking, measurements, and evidence
- Test APIs that conflict with existing `InspectionTestStep`, `InspectionOutcome`, `MeasurementValue`, or evidence metadata names
- JSON fixture assumptions that belong to TASK#5.2
- Commit boundaries that knowingly break compilation without reporting the TDD policy tension
- PR title not starting with `TASK#5.1:`
- Branch name not matching `codex/task-5.1-test-case-model-tests`
- Automatic build/test execution despite the user-run build policy
- Manual validation omissions

Return blockers first, then recommendations, then a final go/no-go.
