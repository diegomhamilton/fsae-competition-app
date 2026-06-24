# Entities Prompt

For this task:

Task: `6.1 Add failing unit tests for InspectionStage, InspectionSection, bundled JSON decoding, display ordering, stable IDs, unsupported step type errors, and malformed JSON failures.`

Identify the core entities and relationships.

Include:

- Domain models that should exist or be extended
- JSON source objects and fields from `Design/Resources/InspectionEvent/*.json`
- Test-only malformed or unsupported-content fixtures
- Error types or result states the tests should expect
- Relationships between stage, section, test case, and test step content
- Fields that must remain stable for navigation, drafts, validation, accessibility, and future UI tests

Required entity coverage:

- `InspectionStage`
- `InspectionSection`
- `InspectionTestCase`
- `InspectionTestStep`
- `InspectionTestStepType`
- `InspectionSafetyBadge`
- Bundled stage resources for Garage, Body, Chassis, EV, Egress, and Rain
- A typed content loading or decoding error for unsupported step types
- A typed content loading or decoding error for malformed JSON

Call out any current model drift or missing fields before proposing tests. In particular, verify whether existing test-case and step models already expose `displayOrder`, stable code generation, draft aggregation helpers, and JSON-compatible initializers on the active branch.
