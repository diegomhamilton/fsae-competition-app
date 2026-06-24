# Operations Prompt

Given this task, approach, and structure:

Task: `6.6 Add structured Strings enums and stable accessibility identifiers to the stage and test case list files.`

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

- Confirm the branch is `codex/task-6.6-stage-accessibility-strings` and based on latest local `develop` if available.
- Create this SPDD prompt folder first and commit it with title `Add TASK#6.6 prompt run`.
- Push the branch after the prompt-only commit and before implementation edits.
- Read OpenSpec context, accessibility/localization spec, TASK#6.3 through TASK#6.5 outputs, stage/list view files, existing string enum examples, and identifier helper tests.
- Inventory raw visible and accessibility strings in stage and test case list files.
- Add structured `Strings` enums for stage title/status copy, section labels, progress/blocker copy, validation summary copy, submit controls, and safety badge text where owned by these views.
- Add stable accessibility identifiers for stage root, test case rows, status indicators, validation summary, submit action, blocked-submit/correction action, section/test case list surfaces, and energized badges.
- Ensure identifiers are derived from stable model IDs rather than localized text.
- Add or update focused unit tests for identifier helper output.
- Keep VoiceOver labels and values meaningful for progress, blockers, validation, and energized safety.
- Avoid dedicated UI automation, snapshot tests, content service changes, validation rule changes, and manual validation docs.
- Do not update the OpenSpec task checkbox unless TASK#6.6 is actually complete.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#6.6: Add stage accessibility IDs`
