# Operations Prompt

Given this task, approach, and structure:

Task: `5.7 Manually validate the Test Case view with mock JSONs and record positive, negative, and edge cases from the .feature file.`

Structure: `<paste structure>`

Decompose this into concrete, reviewable operations.

For each operation, include:

- Exact action
- Expected files or test targets
- Verification command or manual check
- Build ownership: user-run or not applicable
- Manual validation notes to capture when the user builds or inspects locally
- Commit boundary and a proposed commit title of 52 characters or fewer
- Whether the operation can be committed without breaking compilation
- Done condition

Required operation coverage:

- Start from latest `origin/develop` if available.
- Use branch `codex/task-5.7-test-case-validation`.
- Create this SPDD prompt folder first and commit it with title `Add TASK#5.7 prompt run`.
- Push the branch before validation/documentation edits.
- Read OpenSpec proposal, design, tasks, specs, the `.feature` file, prompt template/example, and relevant source/views/fixtures.
- Confirm whether the Test Case view and mock test case JSONs exist on the active branch.
- Prepare or fill a validation artifact covering completed test case, missing required outcome, failed step without notes, valid measurement, invalid measurement, required evidence present/missing, energized badge accessibility, and ordered step display.
- Map positive, negative, and edge cases to `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`.
- Draft PR validation notes with `Summary`, `Scope`, `Notes`, and `Validation`.
- Do not mark OpenSpec TASK#5.7 complete unless actual validation evidence exists.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#5.7: Validate test case view`

