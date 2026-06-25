# Operations Prompt

Given this task, approach, and structure:

Task: `5.1 Add failing unit tests for InspectionTestCase, ordered steps, rule references, draft aggregation, blocker counts, and test case progress.`

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

- Confirm the branch is `codex/task-5.1-test-case-model-tests` and based on latest local `develop`.
- Create this prompt folder and commit it first as prompt-only documentation.
- Push the branch after the prompt-only commit and before implementation edits.
- Inspect existing Swift Testing unit tests and current inspection step model APIs.
- Add failing unit tests for planned `InspectionTestCase` identity, display order, ordered steps, and rule references.
- Add failing unit tests for planned `TestCaseDraft` aggregation from child step drafts.
- Add failing unit tests for blocker counts: missing outcome, failed notes, invalid measurement, and missing evidence.
- Add failing unit tests for test case progress: complete, blocked, and pending step counts or percentages.
- Keep tests aligned with the `.feature` scenarios for open test case from stage, validation blocking, missing notes, measurement, and evidence.
- Avoid TASK#5.2 fixture files and TASK#5.3/TASK#5.4 production implementations.
- Do not update the OpenSpec task checkbox unless TASK#5.1 is actually complete.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#5.1: Add test case model tests`
