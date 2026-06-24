# Operations Prompt

Given this task, approach, and structure:

Task: `6.3 Implement the test case list view from bundled JSON content, grouped by stage sections and ordered by display order.`

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

- Confirm the branch is `codex/task-6.3-test-case-list-view` and based on latest local `develop` if available.
- Create this SPDD prompt folder first and commit it with title `Add TASK#6.3 prompt run`.
- Push the branch after the prompt-only commit and before implementation edits.
- Read OpenSpec context, `.feature` file, TASK#6.1/TASK#6.2 prompts or outputs, source views, design system, bundled JSON resources, and existing tests.
- Confirm `InspectionContentService` can supply loaded stage content or document the blocker.
- Implement a test case list view grouped by sections and ordered by display order.
- Render test case title, code/item ID, rule references, status/progress, blocker summary, and safety badges when available.
- Wire row selection to an injected action or coordinator-ready intent.
- Preserve useful skeleton styling and avoid broad visual redesign.
- Add focused view helper tests for ordering, summary text, and row state if presentation helpers are introduced.
- Avoid `FullStageView` submission controls, energized derived policy, structured string cleanup, accessibility identifier sweep, and manual validation docs.
- Do not update the OpenSpec task checkbox unless TASK#6.3 is actually complete.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#6.3: Add test case list view`
