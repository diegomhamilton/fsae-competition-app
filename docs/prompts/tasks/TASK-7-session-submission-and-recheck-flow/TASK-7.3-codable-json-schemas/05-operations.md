# Operations Prompt

Given this task, approach, and structure:

Task: `7.3 Define Codable JSON schemas for test case draft files and immutable submitted test case/stage snapshot files, including schema version, event ID, team ID, session ID, stage ID, test case ID, updated timestamp, outcomes, notes, measurements, evidence metadata, validation summary, and recheck references.`

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

- Summary: Define Codable v1 draft and submission snapshot schemas with explicit IDs, timestamps, validation, evidence, and recheck references.
- Scope: Draft and snapshot model files; schema fixtures; model tests
- Notes: Split if schema migration or compatibility logic grows beyond initial v1 shape.
- Validation: Swift Testing Codable round-trip and malformed-payload checks.

Task-specific operation plan:

1. Inspect OpenSpec context, the feature scenarios, and the current implementation or docs touched by this task.
2. Create or update only the smallest file set needed for TASK#7.3.
3. Add failing Swift Testing coverage before code behavior where applicable. When the task is part of TASK#8 UI automation, use stable identifiers as selectors.
4. Implement or document the operation without mixing unrelated review contexts.
5. Record validation in the PR description using `Summary`, `Scope`, `Notes`, and `Validation`.
6. Split into a task branch if the work exceeds 10 changed files, mixes unrelated domains, or makes review unsafe.

Do not build automatically unless the user explicitly asks. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#7.3: Codable JSON Schemas`
