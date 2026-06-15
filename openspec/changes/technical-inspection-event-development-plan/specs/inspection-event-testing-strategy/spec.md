## ADDED Requirements

### Requirement: TDD covers Models, Coordinators, Services, and View helpers
The system implementation SHALL add failing tests before behavior for domain models, coordinators, services, and view helpers.

#### Scenario: Model tests cover JSON content
- **WHEN** inspection content models are implemented
- **THEN** unit tests verify JSON decoding, ordering, stable IDs, step types, rule references, badges, and malformed content failures.

#### Scenario: Coordinator tests cover navigation
- **WHEN** coordinators are implemented
- **THEN** unit tests verify login completion, start/resume session, stage selection, test case selection, test step selection, submission result routing, team switching, and recheck review routing.

#### Scenario: Service tests cover validation
- **WHEN** validation services are implemented
- **THEN** unit tests verify missing outcomes, failed-note requirements, measurement parsing, measurement precision, range failures, evidence requirements, and recheck creation.

#### Scenario: View helper tests cover presentation logic
- **WHEN** view helpers are implemented
- **THEN** unit tests verify progress summaries, blocker counts, status text, accessibility identifier construction, and localizable string key selection.

### Requirement: Feature scenarios drive test case selection
The system test plan SHALL map positive, negative, and edge cases back to `inspection_event_use_cases.feature`.

#### Scenario: Positive cases map to feature scenarios
- **WHEN** tests cover successful stage submission, valid measurement entry, evidence attachment, session resume, and history review
- **THEN** the test names or documentation reference the related feature scenario.

#### Scenario: Negative cases map to feature scenarios
- **WHEN** tests cover blocked submission, invalid measurement, missing evidence, missing notes, or unsaved team switching
- **THEN** the test names or documentation reference the related feature scenario.

#### Scenario: Edge cases map to feature scenarios
- **WHEN** tests cover empty history, no started session, blocked team, removing required evidence, or restoring previous team context
- **THEN** the test names or documentation reference the related feature scenario.

### Requirement: UI tests are integrated in a dedicated PR
The system delivery plan SHALL introduce XCUITests and snapshot tests through a dedicated PR after accessibility identifiers and navigation hooks are stable.

#### Scenario: XCUITests cover accessible controls
- **WHEN** the UI test PR is opened
- **THEN** it verifies that session rows, stage rows, test case rows, test step controls, validation summaries, recheck actions, and submission controls are discoverable by accessibility identifier.

#### Scenario: XCUITests cover positive, negative, and edge flows
- **WHEN** the UI test PR is opened
- **THEN** it covers at least one passing submission flow, one blocked submission flow, one invalid measurement flow, one evidence removal flow, one team switch flow, and one recheck resolution flow.

#### Scenario: Snapshot tests cover key states
- **WHEN** snapshot tests are introduced
- **THEN** they capture stable high-value states for test step, test case, stage list, validation blocked, recheck required, and sticker eligible views where practical.

### Requirement: Personas inform testing scenarios
The system test plan SHALL use persona markdown files to discover realistic inspection scenarios.

#### Scenario: Judge persona is prioritized
- **WHEN** test scenarios are drafted
- **THEN** the Judge persona drives the primary inspection, validation, recheck, and accessibility flows.

#### Scenario: Student persona is prioritized
- **WHEN** recheck and sticker eligibility scenarios are drafted
- **THEN** the Student persona drives clarity around failed issues, correction review, and sticker readiness.

#### Scenario: Secondary personas broaden documentation
- **WHEN** documentation and tutorial scenarios are drafted
- **THEN** Professor, Fans, and Sponsors personas are used only where they clarify non-primary stakeholder impact.
