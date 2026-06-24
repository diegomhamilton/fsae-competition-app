# Entities Prompt

Given this task:

Task: `5.2 Add mock JSON fixtures for representative test cases with one step, multiple steps, measurement steps, required evidence, failed notes, and energized badges.`

Identify the domain entities involved.

For each entity, describe:

- Responsibility
- Key fields or state
- Relationships to other entities
- Whether it is immutable content, mutable draft state, UI state, service state, or test fixture data

Include at least:

- `InspectionTestCase`
- `InspectionTestStep`
- Rule reference
- Display order
- Ordered steps
- Measurement step
- Required evidence step
- Failed note case
- Energized safety badge
- Mock fixture folder
- Future fixture loader or decoder

Use the project's inspection-event language: stages, sections, test cases, test steps, outcomes, measurements, evidence, validation, submissions, rechecks, sessions, teams, and judges.

Constraints:

- Keep TASK#5.2 scoped to JSON fixtures and, if needed, minimal fixture loader support.
- Preserve existing `MockInspectionTestSteps/*.json` shape for nested step data.
- Do not add mutable draft state, validation services, coordinators, or SwiftUI view behavior in this task.
