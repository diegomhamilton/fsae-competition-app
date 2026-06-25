# Requirements Prompt

You are helping with SPDD for this task:

Task: `5.2 Add mock JSON fixtures for representative test cases with one step, multiple steps, measurement steps, required evidence, failed notes, and energized badges.`

Branch: `codex/task-5.2-test-case-fixtures`

PR title: `TASK#5.2: Add test case JSON fixtures`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible outcome for a judge viewing mock test cases
- Acceptance source, especially `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`
- Required behavior
- Out of scope behavior
- Completion signal

Keep this focused on what must be true, not how to build it.

Context:

- TASK#5.2 is fixture-only for the Test Case Slice.
- Compose fixtures from the existing `InspectionTestStep` fixture shape.
- Include stable IDs, display/order fields, title, rule references, and ordered steps.
- Cover one-step, multiple-step, measurement, required-evidence, failed-note, and energized-badge cases.
- Keep schema compatible with the future `InspectionTestCase` model and production JSON direction in `inspection-event-json-content`.
- Do not implement production model decoding unless absolutely needed for fixture validity.
- Do not build automatically. The user owns build and validation unless explicitly requested.
