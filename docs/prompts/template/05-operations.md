# Operations Prompt

Given this task, approach, and structure:

Task: `<paste task>`

Structure: `<paste structure>`

Decompose this into concrete, reviewable operations.

For each operation, include:

- Exact action
- Expected files or test targets
- Verification command or manual check
- Build ownership: agent-run, user-run, or not applicable
- Manual validation notes to capture when the user will build or inspect locally
- Commit boundary and a proposed commit title of 52 characters or fewer
- Whether the operation can be committed without breaking compilation
- Done condition

Make the operations small enough for TDD and task-sized commits.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back, and keep the agent's verification to static review unless the user explicitly asks the agent to build.

When a task will become a PR, include the PR title in this format:

`TASK#{TASK NUMBER}: <short task summary>`
