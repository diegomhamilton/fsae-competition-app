# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `6.2 Implement InspectionContentService as an async service that loads the six bundled inspection JSON resources.`

Plan: `<paste operations>`

Review for:

- Skipping TASK#6.1 test contract or overwriting it with implementation-only work
- Loading fewer than all six official bundled JSON resources
- Returning stages in filename order if that can diverge from `displayOrder`
- Presenting partial official content after one resource fails
- Missing typed errors for missing resources, malformed JSON, missing required fields, or unsupported step types
- Mixing mock fixtures with official bundled content
- Editing test case list views, `FullStageView`, accessibility IDs, or view strings too early
- Breaking earlier mock test step or test case fixture loaders
- Ignoring Xcode resource membership
- Automatic build/test execution despite the user-run build policy
- Marking OpenSpec TASK#6.2 complete before service behavior is implemented and verified by user-run tests
- Commit titles longer than 52 characters
- PR title not starting with `TASK#6.2:`
- Prompt folder mixed with implementation files in the prompt-only commit

Return blockers first, then recommendations, then a final go/no-go.
