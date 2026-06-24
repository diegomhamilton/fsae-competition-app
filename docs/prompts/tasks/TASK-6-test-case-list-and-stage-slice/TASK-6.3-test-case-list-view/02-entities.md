# Entities Prompt

For this task:

Task: `6.3 Implement the test case list view from bundled JSON content, grouped by stage sections and ordered by display order.`

Identify the core entities and relationships.

Include:

- View or component names
- Stage, section, test case, and draft/progress inputs
- Row view state needed to show title, rule references, badges, progress, blockers, and status
- Navigation intent outputs for opening a test case
- Existing skeleton views or design-system components to preserve
- Data that should remain separate from localized strings and accessibility identifiers until TASK#6.6

Required entity coverage:

- `InspectionStage`
- `InspectionSection`
- `InspectionTestCase`
- `TestCaseDraft` or equivalent draft/progress data
- Test case row or list component
- Section header component
- Navigation/open-test-case intent

Call out whether the active branch already has a `TestCaseView`, `FullStageView`, and stage row pattern from earlier tasks.
