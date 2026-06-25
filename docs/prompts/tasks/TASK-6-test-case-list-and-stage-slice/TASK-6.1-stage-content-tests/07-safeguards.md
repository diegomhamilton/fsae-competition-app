# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `6.1 Add failing unit tests for InspectionStage, InspectionSection, bundled JSON decoding, display ordering, stable IDs, unsupported step type errors, and malformed JSON failures.`

Plan: `<paste operations>`

Review for:

- Implementing production stage models or `InspectionContentService` instead of adding failing tests
- Editing SwiftUI views, accessibility identifiers, or `Strings` enums that belong to later Milestone 6 tasks
- Claiming bundled JSON loading works before TASK#6.2 implementation exists
- Missing official stage ordering: Garage, Body, Chassis, EV, Egress, Rain
- Missing section ordering coverage
- Missing test case ordering coverage
- Missing step ordering coverage
- Missing stable ID coverage for stages, sections, test cases, and steps
- Missing rule reference preservation coverage
- Missing badge preservation coverage
- Missing step type coverage
- Missing unsupported step type error coverage
- Missing malformed JSON or required-field error coverage
- Tests that rely on SwiftUI views instead of model/domain APIs
- Tests that duplicate TASK#5.1 through TASK#5.7 behavior without extending to stage content
- Missing note about current model/test drift before implementation
- Automatic build/test execution despite the user-run build policy
- Marking OpenSpec TASK#6.1 complete before failing tests are actually added
- Reopening or re-scoping completed TASK#5.7 work from this task
- Commit titles longer than 52 characters
- PR title not starting with `TASK#6.1:`
- Prompt folder mixed with implementation files in the prompt-only commit

Return blockers first, then recommendations, then a final go/no-go.
