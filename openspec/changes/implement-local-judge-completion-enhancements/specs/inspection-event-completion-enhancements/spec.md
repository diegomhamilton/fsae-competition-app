## ADDED Requirements

### Requirement: Evidence capture persists restorable metadata
The system SHALL let a judge capture or select evidence for evidence-required steps and persist restorable metadata in the local test case JSON draft.

#### Scenario: Capture evidence metadata
- **WHEN** a judge captures or selects evidence for a required evidence step
- **THEN** the evidence metadata is saved to the scoped test case JSON draft and restored after relaunch.

#### Scenario: Remove required evidence
- **WHEN** a judge removes the only required evidence metadata from a step
- **THEN** the evidence requirement becomes unsatisfied and stage submission is blocked until evidence is restored.

### Requirement: Failed submitted test cases create rechecks
The system SHALL create open recheck items for failed submitted test cases and close them only after accepted review.

#### Scenario: Failed submission opens recheck
- **WHEN** a submitted test case contains a failed outcome
- **THEN** the system creates an open recheck item referencing the team, stage, test case, rule, failure context, and judge notes.

#### Scenario: Accepted review closes recheck
- **WHEN** a judge accepts a corrected recheck review
- **THEN** the recheck item is closed and historical submission snapshots remain immutable.

### Requirement: Sticker eligibility reflects submissions and rechecks
The system SHALL calculate sticker eligibility from required submitted stages and open rechecks.

#### Scenario: Open recheck blocks sticker
- **WHEN** a team has all required stage submissions but one or more open rechecks
- **THEN** sticker eligibility is blocked with the recheck reason.

#### Scenario: Completed stages and closed rechecks allow sticker
- **WHEN** a team has all required stage submissions and no open rechecks
- **THEN** sticker eligibility is available.

### Requirement: Egress measurement supports stopwatch timing
The system SHALL provide stopwatch-style timing for egress measurement steps while preserving manual override and validation.

#### Scenario: Stopwatch records valid egress time
- **WHEN** the judge starts and stops the egress stopwatch within the allowed range
- **THEN** the measured value is saved to the scoped test case JSON draft and the step no longer appears incomplete.

#### Scenario: Stopwatch supports reset
- **WHEN** the judge resets the stopwatch
- **THEN** the timed value is cleared or returned to incomplete state according to the approved design.

#### Scenario: Manual override remains available
- **WHEN** the judge enters a manual egress measurement
- **THEN** the manual value is validated against the allowed range and persisted as the active measurement.

#### Scenario: Timing is accessible
- **WHEN** stopwatch state changes
- **THEN** assistive technologies announce start, stop, reset, saved value, and validation errors.

