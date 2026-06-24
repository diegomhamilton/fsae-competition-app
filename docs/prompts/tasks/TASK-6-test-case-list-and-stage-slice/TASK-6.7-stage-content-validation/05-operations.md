# Operations Prompt

Given this task, approach, and structure:

Task: `6.7 Manually validate Garage, EV, Egress, and Rain stage content against Design/Resources/InspectionEvent/*.json.`

Structure: `<paste structure>`

Decompose this into concrete, reviewable operations.

For each operation, include:

- Exact action
- Expected files or test targets
- Verification command or manual check
- Build ownership: user-run or not applicable
- Manual validation notes to capture when the user builds or inspects locally
- Commit boundary and proposed commit title of 52 characters or fewer
- Whether the operation can be committed without breaking compilation
- Done condition

Required operation coverage:

- Confirm the branch is `codex/task-6.7-stage-content-validation` and based on latest local `develop` if available.
- Create this SPDD prompt folder first and commit it with title `Add TASK#6.7 prompt run`.
- Push the branch after the prompt-only commit and before validation documentation edits.
- Read OpenSpec context, `.feature` file, TASK#6.1 through TASK#6.6 outputs, bundled JSON files, stage/list views, and accessibility helpers.
- Confirm prerequisites exist or document blockers in the checklist.
- Prepare or fill validation coverage for Garage, EV, Egress, and Rain stage ordering, section grouping, test case ordering, step ordering, rule references, badges, progress, blockers, submit controls, and row navigation.
- Validate energized EV badge visibility and accessibility-equivalent text.
- Validate measurement, required evidence, failed notes, and blocked-submit behavior where the stage content and UI support it.
- Map positive, negative, and edge checks to `.feature` scenarios.
- Draft PR validation notes with `Summary`, `Scope`, `Notes`, and `Validation`.
- Do not mark OpenSpec TASK#6.7 complete unless actual app validation evidence exists.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#6.7: Validate stage content`
