# Entities Prompt

Given this task:

Task: `5.1 Add failing unit tests for InspectionTestCase, ordered steps, rule references, draft aggregation, blocker counts, and test case progress.`

Identify the domain entities involved.

For each entity, describe:

- Responsibility
- Key fields or state
- Relationships to other entities
- Whether it is immutable content, mutable draft state, UI state, service state, or test fixture data

Include at least:

- Judge
- Stage
- `InspectionTestCase`
- `InspectionTestStep`
- Ordered step collection
- Rule reference
- `TestCaseDraft`
- `TestStepDraft`
- `InspectionOutcome`
- `MeasurementValue`
- `EvidenceAttachmentMetadata`
- Validation blocker or issue
- Blocker count
- Test case progress summary

Use the project's inspection-event language: stages, sections, test cases, test steps, outcomes, measurements, evidence, validation, submissions, rechecks, sessions, teams, and judges.

Keep the entity model scoped to tests for TASK#5.1. Mock test data may live in the test file or a tiny test helper, but production test case models and services are out of scope.
