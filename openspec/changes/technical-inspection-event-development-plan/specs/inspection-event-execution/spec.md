## ADDED Requirements

### Requirement: Judge can move from login to an active inspection session
The system SHALL provide a judge-facing flow from login into team session selection and then into an active inspection session.

#### Scenario: Login opens session selector
- **WHEN** a judge completes the mock login flow
- **THEN** the system opens the session selector with the current event team roster and available inspection stages.

#### Scenario: Start new team session
- **WHEN** the judge selects a team with no started inspection session
- **THEN** the system creates a new inspection session, sets the active team context, and opens the first stage, "Garage Inspection".

#### Scenario: Resume existing team session
- **WHEN** the judge selects a team with an in-progress inspection session
- **THEN** the system restores the prior active stage and displays the team as resumable.

### Requirement: Judge can inspect stages, test cases, and test steps
The system SHALL allow a judge to navigate from active team dashboard to stage, test case, and test step views while preserving the active team/session context.

#### Scenario: Open stage from active team dashboard
- **WHEN** the judge opens a stage from the active team dashboard
- **THEN** the system displays the selected stage with its test case list, progress, blockers, and submission controls.

#### Scenario: Open test case from stage
- **WHEN** the judge selects a test case in the stage list
- **THEN** the system displays the test case with ordered test steps, rule references, current outcomes, notes, measurements, evidence status, and recheck status when applicable.

#### Scenario: Open test step from test case
- **WHEN** the judge selects a test step
- **THEN** the system displays the test step detail using the active session draft values and returns edits to the parent test case and stage views.

### Requirement: In-progress test cases are stored as local JSON files
The system SHALL persist each in-progress inspection test case as an individual JSON file in the app's Application Support directory, scoped by event, team, session, stage, and test case.

#### Scenario: Save one draft file per test case
- **WHEN** a judge records an outcome, note, measurement, or evidence metadata value in a test case
- **THEN** the system writes the updated draft to a single JSON file for that test case under `applicationSupportDirectory`.

#### Scenario: Restore draft files after app relaunch
- **WHEN** the app relaunches and the judge resumes an in-progress inspection session
- **THEN** the system restores the prior active stage, nearest valid step context, and draft values from the locally stored test case JSON files.

#### Scenario: Keep test case files isolated by team and session
- **WHEN** two teams have draft data for the same stage or test case identifier
- **THEN** each team's draft values are stored in separate team/session folders and no notes, outcomes, measurements, evidence metadata, submissions, or rechecks leak across teams.

#### Scenario: Group team submissions in local storage
- **WHEN** a stage or test case is submitted
- **THEN** the system stores immutable submission JSON files in a team-specific submissions folder under `applicationSupportDirectory`.

### Requirement: Stage submission is validation gated
The system SHALL block stage submission until required outcomes, failed-step notes, valid measurements, and required evidence are complete.

#### Scenario: Submit valid stage
- **WHEN** every required step in the current stage has a valid accepted outcome and all related policies are satisfied
- **THEN** the system accepts the stage submission and creates an immutable submission snapshot for review.

#### Scenario: Block missing required outcome
- **WHEN** the judge submits a stage with a required outcome missing
- **THEN** the system blocks submission, identifies the invalid step, and allows navigation to the first invalid step.

#### Scenario: Block failed step without required notes
- **WHEN** failed outcomes require inspector notes and a failed step has no notes
- **THEN** the system blocks submission and marks the failed step as requiring notes.

### Requirement: Rechecks are generated from failed test cases
The system SHALL create an open recheck item for any failed inspection test case from the bundled inspection stages.

#### Scenario: Failed test case creates recheck
- **WHEN** a submitted test case has a failed outcome
- **THEN** the system creates an open recheck item referencing the team, stage, test case ID, rule reference, failed outcome, and judge notes.

#### Scenario: Recheck blocks sticker eligibility
- **WHEN** a team has one or more open recheck items
- **THEN** the system marks inspection sticker eligibility as blocked until each recheck is reviewed and accepted by a judge.

#### Scenario: Judge accepts corrected recheck
- **WHEN** the team fixes a failed test case and the judge records an accepted recheck review
- **THEN** the system closes the recheck item and recalculates sticker eligibility.

### Requirement: Team switching preserves draft isolation
The system SHALL preserve unsaved draft work and isolate inspection state by team and session.

#### Scenario: Confirm switch with unsaved work
- **WHEN** the judge switches teams while the active session has unsaved draft changes
- **THEN** the system asks for confirmation and saves the current draft before loading the target team.

#### Scenario: Prevent draft leakage between teams
- **WHEN** the judge switches from one team to another
- **THEN** the system displays only the target team's draft notes, outcomes, measurements, evidence, submissions, and rechecks.

#### Scenario: Restore previous team context
- **WHEN** the judge switches back to a previously active team
- **THEN** the system restores that team's last saved stage, nearest valid step context, and draft values.
