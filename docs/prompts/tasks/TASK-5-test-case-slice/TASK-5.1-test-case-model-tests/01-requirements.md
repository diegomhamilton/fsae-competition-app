# Requirements Prompt

You are helping with SPDD for this task:

Task: `5.1 Add failing unit tests for InspectionTestCase, ordered steps, rule references, draft aggregation, blocker counts, and test case progress.`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible outcome for a judge opening a test case from a stage
- Acceptance source, especially `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`
- Required behavior
- Out of scope behavior
- Completion signal

Keep this focused on what must be true, not how to build it.

Context:

- Branch: `codex/task-5.1-test-case-model-tests`
- Expected PR title: `TASK#5.1: Add test case model tests`
- This task is the first test-only checkpoint in the Test Case Slice.
- The tests must intentionally describe missing production behavior for later TASK#5.3 and TASK#5.4 work.
- Align with feature scenarios for opening a test case from a stage, validation blocking, failed notes, measurements, and evidence requirements.
- Do not implement production models or validation services in this task.
- Do not build automatically. The user owns build and validation unless explicitly requested.
