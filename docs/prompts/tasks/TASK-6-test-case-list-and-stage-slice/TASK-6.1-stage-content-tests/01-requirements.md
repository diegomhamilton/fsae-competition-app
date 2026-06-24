# Requirements Prompt

You are helping with SPDD for this task:

Task: `6.1 Add failing unit tests for InspectionStage, InspectionSection, bundled JSON decoding, display ordering, stable IDs, unsupported step type errors, and malformed JSON failures.`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible outcome for a judge opening an official inspection stage
- Acceptance source, especially `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`
- JSON-content source, especially `Design/Resources/InspectionEvent/*.json`
- Required behavior
- Out of scope behavior
- Completion signal

Keep this focused on what must be true, not how to build it.

Context:

- Branch: `codex/task-6.1-stage-content-tests`
- Expected PR title: `TASK#6.1: Add stage content tests`
- This task is the first test-only checkpoint in the Test Case List and Stage Slice.
- The tests must intentionally describe missing production behavior for later TASK#6.2 through TASK#6.6 work.
- Align with OpenSpec `inspection-event-json-content`, `inspection-event-execution`, and `inspection-event-testing-strategy`.
- Cover ordered stages, ordered sections, ordered test cases, ordered steps, stable IDs, rule references, badges, step types, and typed decoding failures.
- Do not implement `InspectionContentService`, stage views, accessibility IDs, or production JSON decoding fixes in this task unless the task scope is explicitly revised.
- Do not build automatically. The user owns build and validation unless explicitly requested.
