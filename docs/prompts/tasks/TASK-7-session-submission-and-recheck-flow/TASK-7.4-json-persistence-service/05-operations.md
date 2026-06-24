# Operations Prompt

Given this task, approach, and structure:

Task: `7.4 Implement an actor-isolated JSON file persistence service that creates the Application Support folder tree, writes each test case draft atomically, deletes or archives stale draft files after submission, and restores drafts after app relaunch.`

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

Operation-first PR summary:

- Summary: Implement actor-isolated JSON draft persistence with atomic writes, folder creation, stale draft cleanup, and relaunch restore.
- Scope: Persistence service; file helpers; persistence tests
- Notes: Split from schemas if implementation touches more than persistence service plus tests.
- Validation: Swift Testing for actor-isolated writes, restore, atomic replacement, and cleanup.

Task-specific operation plan:

1. Inspect OpenSpec context, the feature scenarios, and the current implementation or docs touched by this task.
2. Create or update only the smallest file set needed for TASK#7.4.
3. Add failing Swift Testing coverage before code behavior where applicable. When the task is part of TASK#8 UI automation, use stable identifiers as selectors.
4. Implement or document the operation without mixing unrelated review contexts.
5. Record validation in the PR description using `Summary`, `Scope`, `Notes`, and `Validation`.
6. Split into a task branch if the work exceeds 10 changed files, mixes unrelated domains, or makes review unsafe.

Do not build automatically unless the user explicitly asks. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#7.4: JSON Persistence Service`
