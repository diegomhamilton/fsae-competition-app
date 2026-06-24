# Structure Prompt

For this task:

Task: `6.1 Add failing unit tests for InspectionStage, InspectionSection, bundled JSON decoding, display ordering, stable IDs, unsupported step type errors, and malformed JSON failures.`

Define the implementation structure before writing tests.

Include:

- Files to inspect first
- Files that may be added or edited
- Test grouping and test naming structure
- Test helper structure
- Expected compile or failure state after the task
- Commit boundaries

Expected files to inspect:

- `openspec/changes/technical-inspection-event-development-plan/proposal.md`
- `openspec/changes/technical-inspection-event-development-plan/design.md`
- `openspec/changes/technical-inspection-event-development-plan/tasks.md`
- `openspec/changes/technical-inspection-event-development-plan/specs/inspection-event-json-content/spec.md`
- `openspec/changes/technical-inspection-event-development-plan/specs/inspection-event-execution/spec.md`
- `openspec/changes/technical-inspection-event-development-plan/specs/inspection-event-testing-strategy/spec.md`
- `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`
- `Design/Resources/InspectionEvent/*.json`
- Existing model and validation tests under `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklistTests/`
- Existing inspection content models under `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/`

Expected edit scope:

- Add this prompt folder first.
- Add or update only test files needed for TASK#6.1 after the prompt commit.
- Avoid production implementation files unless a tiny test-target compile shim is already established by the repo's TDD pattern.
- Avoid OpenSpec checkbox updates unless TASK#6.1 is actually complete.

Recommended commit sequence:

- `Add TASK#6.1 prompt run`
- `Add stage content tests`

Return the proposed file tree and explain whether each file belongs to prompt setup, failing tests, or later implementation.
