# Operations Prompt

Given this task, approach, and structure:

Task: `6.2 Implement InspectionContentService as an async service that loads the six bundled inspection JSON resources.`

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

- Confirm the branch is `codex/task-6.2-content-service` and based on latest local `develop` if available.
- Create this SPDD prompt folder first and commit it with title `Add TASK#6.2 prompt run`.
- Push the branch after the prompt-only commit and before implementation edits.
- Read OpenSpec proposal, design, tasks, specs, `.feature` file, TASK#6.1 prompt/tests, source models, fixture loaders, bundled JSON resources, and Xcode project resource settings.
- Confirm TASK#6.1 tests exist or document how this task will add the minimum service tests needed without replacing TASK#6.1.
- Implement or complete `InspectionStage` and `InspectionSection` decoding support if still missing.
- Implement `InspectionContentService` async loading for the six bundled stage JSON files.
- Preserve official display order and stable IDs.
- Add typed failures for missing resource, malformed JSON, missing required field, and unsupported step type.
- Ensure the service returns no partial official content after a load failure.
- Keep mock fixture loaders from earlier tasks working.
- Avoid test case list views, `FullStageView`, energized policy derivation, accessibility IDs, view strings, and manual validation docs.
- Do not update the OpenSpec task checkbox unless TASK#6.2 is actually complete.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#6.2: Add content service`
