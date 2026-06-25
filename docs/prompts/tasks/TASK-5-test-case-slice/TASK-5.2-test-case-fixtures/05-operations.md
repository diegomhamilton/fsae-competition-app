# Operations Prompt

Given this task, approach, and structure:

Task: `5.2 Add mock JSON fixtures for representative test cases with one step, multiple steps, measurement steps, required evidence, failed notes, and energized badges.`

Structure: `<paste structure>`

Decompose this into concrete, reviewable operations.

For each operation, include:

- Exact action
- Expected files or test targets
- Verification command or manual check
- Build ownership: user-run
- Manual validation notes to capture when the user builds or inspects locally
- Commit boundary and proposed commit title of 52 characters or fewer
- Whether the operation can be committed without breaking compilation
- Done condition

Required operation coverage:

- Create `docs/prompts/tasks/TASK-5-test-case-slice/TASK-5.2-test-case-fixtures/` from the SPDD prompt template and TASK#5.0 example.
- Commit and push the prompt-only change before implementation edits.
- Add mock test case JSON fixtures under a dedicated folder such as `MockInspectionTestCases`.
- Include one-step, multi-step, measurement, required-evidence, failed-note, and energized-badge representative fixtures.
- Compose nested `steps` from the existing `InspectionTestStep` fixture field shape.
- Include stable test case IDs, display/order fields, titles, rule references, and ordered steps.
- Keep schema compatible with future `InspectionTestCase` model and `inspection-event-json-content`.
- Update OpenSpec task checkbox only after fixture work is complete.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back, and keep agent verification to static review unless the user explicitly asks the agent to build.

When this task becomes a PR, use this title:

`TASK#5.2: Add test case JSON fixtures`
