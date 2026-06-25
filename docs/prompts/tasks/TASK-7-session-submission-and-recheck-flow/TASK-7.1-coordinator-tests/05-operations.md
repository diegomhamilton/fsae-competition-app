# Operations Prompt

Given this task, approach, and structure:

Task: `7.1 Add failing coordinator tests for mock login completion, session selector routing, start session, resume session, stage selection, team switching, and restored context.`

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

- Summary: Add failing Swift Testing coverage for session-flow coordinator behavior before coordinator implementation.
- Scope: FSAEInspectionChecklistTests/*CoordinatorTests.swift; coordinator fixtures/helpers
- Notes: Split if coordinator fixtures or navigation helpers exceed one focused test file group.
- Validation: Swift Testing failures first, then passing tests after coordinator implementation.

Task-specific operation plan:

1. Inspect OpenSpec context, the feature scenarios, and the current implementation or docs touched by this task.
2. Create or update only the smallest file set needed for TASK#7.1.
3. Add failing Swift Testing coverage before code behavior where applicable. When the task is part of TASK#8 UI automation, use stable identifiers as selectors.
4. Implement or document the operation without mixing unrelated review contexts.
5. Record validation in the PR description using `Summary`, `Scope`, `Notes`, and `Validation`.
6. Split into a task branch if the work exceeds 10 changed files, mixes unrelated domains, or makes review unsafe.

Do not build automatically unless the user explicitly asks. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#7.1: Coordinator Tests`
