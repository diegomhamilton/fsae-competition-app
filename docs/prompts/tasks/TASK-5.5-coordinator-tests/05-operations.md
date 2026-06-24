# Operations Prompt

Given this task, approach, and structure:

Task: `5.5 Add coordinator tests for opening a test case, opening a test step, applying edits, and returning edits to the parent test case.`

Structure: `<paste structure>`

Decompose this into concrete, reviewable operations.

For each operation, include:

- Exact action
- Expected files or test targets
- Verification command or manual check
- Build ownership: user-run
- Manual validation notes to capture when the user builds or inspects locally
- Commit boundary and a proposed commit title of 52 characters or fewer
- Whether the operation can be committed without breaking compilation
- Done condition

Required operation coverage:

- Read OpenSpec proposal, design, specs, tasks, and the inspection-event feature file before coding.
- Read existing Swift models, drafts, coordinator/view-model-like types, and Swift Testing tests.
- Add failing Swift Testing coverage for opening a test case from stage/list context.
- Add failing Swift Testing coverage for opening a test step from the selected test case.
- Add failing Swift Testing coverage for applying draft edits to the active test step.
- Add failing Swift Testing coverage for returning edited step draft state to the parent test case draft.
- Add the smallest production coordinator or coordinator contract needed for those tests if no existing coordinator type covers the behavior.
- Keep the scope to active test case and active test step draft handoff.
- Avoid full app/session coordinator work planned for task `7.x`.
- Avoid UI tests.
- Update the OpenSpec task checkbox only after coordinator tests and minimal supporting coordinator behavior are complete.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#5.5: Add test case coordinator tests`

Commit title candidates:

- `Add TASK#5.5 prompt run`
- `Add test case coordinator tests`
- `Add test case draft handoff`
