# Structure Prompt

For this task:

Task: `6.2 Implement InspectionContentService as an async service that loads the six bundled inspection JSON resources.`

Define the implementation structure before editing code.

Include:

- Files to inspect first
- Files that may be added or edited
- Service and model placement
- Test placement
- Resource/project membership checks
- Expected compile state after the task
- Commit boundaries

Expected files to inspect:

- OpenSpec proposal, design, tasks, and specs
- `Design/Resources/InspectionEvent/*.json`
- `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/InspectionTestCaseModels.swift`
- `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/InspectionTestStepModels.swift`
- Existing fixture loaders and validation services
- Existing unit tests, especially TASK#6.1 tests once present
- `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist.xcodeproj/project.pbxproj`

Expected edit scope:

- Add this prompt folder first.
- Implement service/model/error changes needed to satisfy TASK#6.1 and TASK#6.2 service tests.
- Update Xcode resource membership only if required for bundled loading.
- Avoid SwiftUI stage/list view edits.
- Avoid OpenSpec checkbox updates unless TASK#6.2 is actually complete.

Recommended commit sequence:

- `Add TASK#6.2 prompt run`
- `Add inspection content service`
- `Bundle inspection JSON resources` if project membership changes are needed

Return the proposed file tree and explain which files are production, test, resource, or prompt-only.
