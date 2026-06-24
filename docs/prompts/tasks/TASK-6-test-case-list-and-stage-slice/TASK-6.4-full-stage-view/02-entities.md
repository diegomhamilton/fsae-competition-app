# Entities Prompt

For this task:

Task: `6.4 Refactor FullStageView to render real stage content, stage progress, validation blockers, and submit controls from model state.`

Identify the core entities and relationships.

Include:

- Stage-level model and draft state
- Stage progress summary
- Validation summary and first-blocking-test-case or step routing data
- Submit control state
- Test case list child view
- Existing coordinator or closure-based intents
- Skeleton UI elements to preserve

Required entity coverage:

- `FullStageView`
- `InspectionStage`
- `InspectionSection`
- `InspectionTestCase`
- `TestCaseDraft`
- `InspectionValidationService`
- Stage progress or summary helper
- Submit intent and blocked-submit intent

Call out whether a stage-level draft model exists or whether this task should add the smallest model/helper needed to aggregate existing test case drafts.
