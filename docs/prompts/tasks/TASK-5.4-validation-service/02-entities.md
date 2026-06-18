# Entities Prompt

Given this task:

Task: `5.4 Implement InspectionValidationService rules for missing outcome, failed note requirement, invalid measurement, and missing evidence.`

Identify the domain entities involved.

For each entity, describe:

- Responsibility
- Key fields or state
- Relationships to other entities
- Whether it is immutable content, mutable draft state, UI state, service state, or test fixture data

Include at least:

- Judge
- Inspection stage submission intent
- `InspectionTestStep`
- `InspectionOutcome`
- `MeasurementValue`
- `MeasurementRange`
- `EvidenceAttachmentMetadata`
- Draft step state such as `StepResult` or `TestStepDraft`
- `ValidationIssue`
- `InspectionValidationService`
- Existing `ValidationService` compatibility surface, if present

Use the project's inspection-event language: stages, sections, test cases, test steps, outcomes, measurements, evidence, validation, submissions, rechecks, sessions, teams, and judges.

Keep real submission snapshot creation and recheck creation out of scope.
