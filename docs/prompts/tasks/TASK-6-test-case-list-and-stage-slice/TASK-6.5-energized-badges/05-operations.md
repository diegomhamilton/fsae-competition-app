# Operations Prompt

Given this task, approach, and structure:

Task: `6.5 Add energized dynamic test badge derivation for EV inspection steps and expose equivalent accessibility information.`

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

- Confirm the branch is `codex/task-6.5-energized-badges` and based on latest local `develop` if available.
- Create this SPDD prompt folder first and commit it with title `Add TASK#6.5 prompt run`.
- Push the branch after the prompt-only commit and before implementation edits.
- Read OpenSpec context, accessibility spec, JSON-content spec, EV bundled JSON, badge models, stage/list views, and existing tests.
- Identify and document the energized dynamic test derivation rule before implementing it.
- Add tests that energized EV dynamic test steps receive `InspectionSafetyBadge.energized`.
- Add tests that non-energized EV steps and non-EV stages do not receive false-positive energized badges.
- Implement badge derivation or content normalization without duplicating existing explicit badges.
- Expose visible `CAUTION: ENERGIZED` text and equivalent accessibility label/value through existing badge rendering or view-state paths.
- Ensure the safety state uses text/accessibility information and not color alone.
- Avoid the full TASK#6.6 accessibility ID and structured string sweep.
- Do not update the OpenSpec task checkbox unless TASK#6.5 is actually complete.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#6.5: Add energized badges`
