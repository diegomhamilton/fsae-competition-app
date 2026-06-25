# Entities Prompt

For this task:

Task: `6.6 Add structured Strings enums and stable accessibility identifiers to the stage and test case list files.`

Identify the core entities and relationships.

Include:

- View files requiring `Strings` enums
- Visible text, accessibility labels, hints, and values
- Stable accessibility identifier helpers
- Identifiers for stage, section, test case rows, status, validation summary, submit, blocked submit, and energized badges
- Existing `InspectionAccessibilityIdentifier` helpers to extend or reuse
- Tests for identifier construction or string key helper selection

Required entity coverage:

- `FullStageView`
- Stage/test case list view from TASK#6.3
- `InspectionAccessibilityIdentifier`
- Validation summary identifier
- Submit action identifier
- Test case row identifier
- Section header or status identifier where actionable or test-relevant
- Energized badge accessibility text from TASK#6.5

Call out which strings are display strings versus stable IDs so they do not get conflated.
