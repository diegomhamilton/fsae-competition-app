## ADDED Requirements

### Requirement: Task 10 cannot start with unresolved Task 9 review issues
The workflow SHALL review and resolve required GitHub feedback on the Task 9 organization PR before Task 10 implementation begins.

#### Scenario: No review issues exist
- **WHEN** the Task 9 PR has no comments, review submissions, or inline review threads
- **THEN** the readiness gate records that no GitHub fixes are required.

#### Scenario: Required review issue exists
- **WHEN** a GitHub review identifies a build, behavior, documentation, organization, or header issue in Task 9
- **THEN** the issue is fixed and verified on the Task 9 branch before Task 10 implementation starts.

#### Scenario: Follow-up review issue exists
- **WHEN** a GitHub review asks for work outside Task 9 readiness
- **THEN** the follow-up is assigned to the correct later OpenSpec plan instead of being lost.

### Requirement: Current-plan leftovers are explicitly classified
The workflow SHALL classify unchecked tasks from the current technical inspection event plan before proceeding to Task 10.

#### Scenario: Manual validation remains
- **WHEN** manual validation tasks remain from earlier slices
- **THEN** the readiness gate records whether they are completed now or carried into a later plan with rationale.

#### Scenario: Dedicated UI tests remain
- **WHEN** dedicated UI test tasks remain unchecked
- **THEN** they stay scoped to the dedicated UI test plan and do not block Task 10 design review unless navigation or accessibility hooks are missing.

