## ADDED Requirements

### Requirement: Judge screens show active local inspection context
The system SHALL make event, team, session, stage, test case, saved draft state, and next action clear on judge-facing screens.

#### Scenario: Restored session context is clear
- **WHEN** a judge resumes an in-progress team session after relaunch
- **THEN** the UI shows the active team, restored stage, draft saved state, and next useful action.

#### Scenario: Prototype copy is removed
- **WHEN** a judge uses Session, Dashboard, Stage, Test Case, Step, or Team Switch screens
- **THEN** the UI does not describe the flow as mock, prototype, or placeholder state.

### Requirement: Validation blockers are actionable
The system SHALL allow a judge to select a validation blocker and focus the missing or invalid control.

#### Scenario: Missing outcome blocker focuses outcome
- **WHEN** the validation summary identifies a missing required outcome
- **THEN** selecting the blocker focuses or routes to the outcome control for that step.

#### Scenario: Missing note blocker focuses notes
- **WHEN** the validation summary identifies a failed outcome without required notes
- **THEN** selecting the blocker focuses or routes to the notes control.

#### Scenario: Missing evidence blocker focuses evidence
- **WHEN** the validation summary identifies missing required evidence
- **THEN** selecting the blocker focuses or routes to the evidence control.

#### Scenario: Correction persists immediately
- **WHEN** the judge corrects a focused validation blocker
- **THEN** the corrected value is written to the local test case JSON draft.

### Requirement: Incomplete state is distinct from judge outcomes
The system SHALL present unanswered required steps as incomplete state instead of a judge-selected Pending outcome.

#### Scenario: Required step has no selected outcome
- **WHEN** a required step has not been answered
- **THEN** the UI labels it as incomplete or needs outcome rather than presenting Pending as a selected decision.

#### Scenario: Judge-selected outcomes remain explicit
- **WHEN** the judge selects Pass, Fail, or N/A
- **THEN** the UI reflects that explicit choice and validation uses the selected outcome.

### Requirement: Notes and evidence labels reflect state
The system SHALL label notes and evidence controls according to whether data is absent, required, present, or editable.

#### Scenario: Evidence required and missing
- **WHEN** a step requires evidence and none is attached
- **THEN** the UI labels the state as required evidence missing and exposes an add evidence action.

#### Scenario: Evidence present
- **WHEN** one or more evidence metadata records exist
- **THEN** the UI displays the evidence count and an edit or remove path.

#### Scenario: Notes are absent or present
- **WHEN** no notes exist
- **THEN** the UI offers add note.
- **WHEN** notes exist
- **THEN** the UI offers edit note.

