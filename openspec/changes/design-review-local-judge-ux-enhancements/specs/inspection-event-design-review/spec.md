## ADDED Requirements

### Requirement: Task 10 has an approved design before implementation
The workflow SHALL complete a design review for Task 10 enhancements before implementation begins.

#### Scenario: Design review maps tasks to requirements
- **WHEN** Task 10 design review is performed
- **THEN** each Task 10 item is mapped to a feature scenario, existing spec requirement, or explicit follow-up rationale.

#### Scenario: Design review rejects unclear UX
- **WHEN** a Task 10 proposal leaves active context, validation recovery, evidence storage, recheck lifecycle, sticker eligibility, or stopwatch behavior ambiguous
- **THEN** implementation is blocked until the ambiguity is resolved.

#### Scenario: Design review approves implementation split
- **WHEN** the design review is complete
- **THEN** Task 10 work is split into UX foundation and completion-enhancement implementation plans with clear dependencies.

### Requirement: Proposed UX supports fully local stored inspection
The design SHALL support a judge completing a local stored inspection using restored drafts, validation, evidence metadata, submitted snapshots, rechecks, and sticker eligibility.

#### Scenario: Relaunch restore is understandable
- **WHEN** the app restores an in-progress inspection after relaunch
- **THEN** the design shows active event, team, session, stage, test case, saved state, and next action clearly.

#### Scenario: Validation recovery is actionable
- **WHEN** submission is blocked by validation
- **THEN** the design lets the judge select the blocker and reach the missing outcome, note, measurement, or evidence control.

#### Scenario: Completion enhancements preserve storage boundaries
- **WHEN** camera evidence, rechecks, sticker eligibility, or stopwatch timing are proposed
- **THEN** the design identifies what is persisted locally now and what remains behind a future storage or sync policy.

