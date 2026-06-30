# Operations Prompt

Given this task, approach, and structure:

Task: `7.7 Implement InspectionEventStore as an actor-isolated event/session source of truth with scoped queries by event, team, session, user access, and the JSON file persistence service.`

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

- Summary: Verify or implement actor-isolated InspectionEventStore with scoped event/team/session/user queries backed by persistence.
- Scope: InspectionEventStore; query models; store tests
- Notes: Split from coordinators if store APIs are still changing.
- Validation: Swift Testing for scoped queries, access isolation, async mutation behavior, and explicit success events if success must be queried outside signpost intervals.

Task-specific operation plan:

1. Inspect OpenSpec context, the feature scenarios, and the current implementation or docs touched by this task.
2. Create or update only the smallest file set needed for TASK#7.7.
3. Add failing Swift Testing coverage before code behavior where applicable. When the task is part of TASK#8 UI automation, use stable identifiers as selectors.
4. Implement or document the operation without mixing unrelated review contexts.
5. Record validation in the PR description using `Summary`, `Scope`, `Notes`, and `Validation`.
6. Split into a task branch if the work exceeds 10 changed files, mixes unrelated domains, or makes review unsafe.

Do not build automatically unless the user explicitly asks. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#7.7: Inspection Event Store`
