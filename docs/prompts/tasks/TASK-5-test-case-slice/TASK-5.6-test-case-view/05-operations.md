# Operations Prompt

Given this task, approach, and structure:

Task: `5.6 Refactor the existing stage step card pattern into a test case view that renders ordered steps and validation summaries.`

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

- Confirm branch `codex/task-5.6-test-case-view`.
- Create and commit this prompt folder first with `Add TASK#5.6 prompt run`.
- Push the prompt-only branch before implementation edits.
- Read OpenSpec proposal/design/tasks/specs and the relevant `.feature` file.
- Read `agents/SwiftAgents/AGENTS.md`.
- Read current stage and step views, `KeyboardDismissBar.swift`, and relevant task 5.3/5.4 models or services if present.
- Extract or reuse the existing stage step card pattern as a dedicated Test Case view.
- Render ordered test steps from mock JSON/model state.
- Render validation summaries from model or service state.
- Add structured `Strings` enum values for new user-visible text.
- Add stable accessibility identifiers for actionable controls and statuses introduced here.
- Preserve one keyboard dismissal affordance for repeated note inputs, respecting TASK#5.0 behavior.
- Add view helper/model tests where practical; otherwise document the manual validation path.
- Do not implement bundled stage loading; that belongs to task 6.x.
- Do not add UI tests.
- Update the OpenSpec task checkbox only after the view work is actually complete.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#5.6: Add test case view`
