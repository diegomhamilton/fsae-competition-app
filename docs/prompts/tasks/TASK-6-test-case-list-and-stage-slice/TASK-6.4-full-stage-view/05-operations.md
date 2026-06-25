# Operations Prompt

Given this task, approach, and structure:

Task: `6.4 Refactor FullStageView to render real stage content, stage progress, validation blockers, and submit controls from model state.`

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

- Confirm the branch is `codex/task-6.4-full-stage-view` and based on latest local `develop` if available.
- Create this SPDD prompt folder first and commit it with title `Add TASK#6.4 prompt run`.
- Push the branch after the prompt-only commit and before implementation edits.
- Read OpenSpec context, `.feature` file, TASK#6.2/TASK#6.3 outputs, stage/list views, validation service, test case models, and existing view-state tests.
- Confirm `FullStageView` can receive or load a real `InspectionStage`; document any content-service blocker.
- Render stage title, sectioned test case list, progress, blocker count, and submit controls from model/draft state.
- Use validation results to block submit and identify the first invalid test case or step.
- Route open-test-case, submit, and blocked-submit correction actions through injected closures or coordinator-ready intents.
- Add focused tests for stage progress and blocked-submit summary helpers when introduced.
- Preserve skeleton layout where useful and keep statuses understandable without color alone.
- Avoid submission snapshots, rechecks, sticker eligibility, energized derived badge policy, accessibility sweep, and manual validation docs.
- Do not update the OpenSpec task checkbox unless TASK#6.4 is actually complete.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#6.4: Refactor full stage view`
