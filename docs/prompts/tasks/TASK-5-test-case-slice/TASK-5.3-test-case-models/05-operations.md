# Operations Prompt

Given this task, approach, and structure:

Task: `5.3 Implement test case models and draft state composition from test step drafts.`

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

- Read current `develop` source and ignore stale untracked artifacts unless they match current needs.
- Add or update focused unit tests for `InspectionTestCase`, ordered steps, rule references, draft aggregation, blocker counts, and progress.
- Implement `InspectionTestCase` as a stable, Codable, Hashable, Sendable domain model where appropriate.
- Add draft aggregation/composition from existing `InspectionTestStep` and `StepResult` / `TestStepDraft` concepts.
- Preserve step order exactly as content provides it.
- Derive progress from composed step draft state without implementing the full TASK#5.4 validation service.
- Avoid TASK#5.6 UI refactors.
- Update the OpenSpec task checkbox only after production model work is complete and verified as far as policy allows.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#5.3: Implement test case models`

Commit title candidates:

- `Add test case domain models`
- `Compose test case draft state`
- `Add test case model tests`
