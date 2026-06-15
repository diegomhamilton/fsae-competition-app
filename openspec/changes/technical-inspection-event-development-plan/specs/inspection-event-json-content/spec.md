## ADDED Requirements

### Requirement: Bundled inspection JSON defines official offline stages
The system SHALL load official inspection stages from the bundled JSON files under `Design/Resources/InspectionEvent/` for offline use.

#### Scenario: Load ordered stages
- **WHEN** inspection content is loaded
- **THEN** the system returns Garage Inspection, Body Inspection, Chassis Inspection, EV Inspection, Egress Test, and Rain Test in display order.

#### Scenario: Decode stage structure
- **WHEN** a stage JSON file is decoded
- **THEN** the system creates stage, section, test case, and test step models with stable IDs, titles, display order, rule references, badges, step types, and content.

#### Scenario: Fail clearly on malformed content
- **WHEN** a bundled JSON file is missing required fields or contains unsupported step types
- **THEN** the system reports a typed content loading error without presenting partial corrupted inspection content as official.

### Requirement: JSON-backed content supports the incremental development flow
The system SHALL support mock JSON fixtures for leaf views before replacing them with bundled stage JSON loading.

#### Scenario: Test step view uses mock JSON
- **WHEN** the first implementation slice runs
- **THEN** the test step view renders from a mock JSON fixture that matches the production model shape.

#### Scenario: Test case view uses mock JSON
- **WHEN** the second implementation slice runs
- **THEN** the test case view composes ordered test steps from a mock JSON fixture that matches the production model shape.

#### Scenario: Test case list uses bundled JSON
- **WHEN** the third implementation slice runs
- **THEN** the test case list and stage views render from the bundled inspection JSON resources.

### Requirement: Inspection content preserves safety metadata
The system SHALL surface safety badges and energized dynamic test indicators from inspection content or derived policy metadata.

#### Scenario: Highlight energized dynamic test steps
- **WHEN** an EV inspection step belongs to the energized dynamic test range
- **THEN** the system displays a visible "CAUTION: ENERGIZED" safety badge and exposes equivalent accessibility information.

#### Scenario: Preserve rule references
- **WHEN** a judge views a test case or test step
- **THEN** the system displays the related rule reference from the JSON content.
