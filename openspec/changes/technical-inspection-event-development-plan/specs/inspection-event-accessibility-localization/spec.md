## ADDED Requirements

### Requirement: Views expose stable accessibility identifiers
The system SHALL assign stable accessibility identifiers to user-actionable controls, navigation destinations, status indicators, validation summaries, recheck indicators, and sticker eligibility indicators.

#### Scenario: Session selector identifiers
- **WHEN** the session selector is displayed
- **THEN** each team row, status label, resume indicator, blocked indicator, and selection action has a stable accessibility identifier.

#### Scenario: Stage and test case identifiers
- **WHEN** the stage or test case view is displayed
- **THEN** each test case row, test step row, outcome control, notes field, measurement field, evidence control, validation summary, and submit action has a stable accessibility identifier.

#### Scenario: Recheck identifiers
- **WHEN** a test case has an open recheck
- **THEN** the recheck badge, review action, and resolved status have stable accessibility identifiers.

### Requirement: VoiceOver can complete inspection flows
The system SHALL allow VoiceOver users to complete login, session selection, stage inspection, validation correction, submission, team switching, and recheck review flows.

#### Scenario: VoiceOver navigates validation correction
- **WHEN** stage submission is blocked
- **THEN** VoiceOver announces the validation summary and the judge can navigate to the first invalid step.

#### Scenario: VoiceOver understands safety badges
- **WHEN** an energized safety badge is visible
- **THEN** VoiceOver announces the safety state with meaningful text, not only color or icon information.

#### Scenario: VoiceOver completes recheck review
- **WHEN** a judge reviews an open recheck
- **THEN** VoiceOver exposes the failed test case, required correction context, review outcome control, and save action.

### Requirement: Visual design supports accessible inspection work
The system SHALL avoid relying on color alone and SHALL maintain usable contrast for inspection status, validation errors, safety badges, and recheck states.

#### Scenario: Status has non-color cue
- **WHEN** a status is shown as passed, failed, pending, blocked, or recheck required
- **THEN** the system pairs color with text, icon, or shape information.

#### Scenario: High-risk safety state is distinguishable
- **WHEN** an energized EV step is displayed
- **THEN** the system uses text and accessible labeling in addition to visual color treatment.

### Requirement: Display strings use localizable structured constants
The system SHALL define display strings through structured per-file constant enums that can be migrated to localized resources.

#### Scenario: View strings are centralized
- **WHEN** a SwiftUI view introduces user-visible text
- **THEN** the view file defines or uses a structured `Strings` enum rather than scattering raw literals through the body.

#### Scenario: Accessibility strings are localizable
- **WHEN** a control has an accessibility label, hint, or value
- **THEN** those strings are defined through the same localizable string structure as visible text.
