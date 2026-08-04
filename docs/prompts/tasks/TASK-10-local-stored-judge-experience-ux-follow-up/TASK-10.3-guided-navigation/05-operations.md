# Operations Prompt

Given this task, approach, and structure:

Task: `10.3 Refactor judge navigation so Sessions, Team, and Stage are the top-level landmarks, remove the standalone Case tab, and make Stage contain the case UI with dominant next-action and focused one-step editing.`

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

- Summary: Implement guided judge navigation so Stage owns case-level execution UI and the standalone Case tab is removed.
- Scope: ContentTabsView; ProposedScreen; AppCoordinator/InspectionExecutionCoordinator route handling; FullStageView; TestCaseView; view state; tests
- Notes: Split if route model changes and Stage/Case UI composition cannot be reviewed together.
- Validation: Swift Testing for route transitions plus manual one-step, multi-step, relaunch restore, empty-state, and VoiceOver checks.

Task-specific operation plan:

1. Inspect OpenSpec context, the feature scenarios, and the current implementation or docs touched by this task.
2. Add failing Swift Testing coverage for the desired route model: no standalone Case tab, stage-to-case selection remains inside Stage, step detail remains a guided drill-in, and invalid context routes to the next useful empty-state action.
3. Refactor the tab model so only `Sessions`, `Team`, and `Stage` are top-level judge landmarks; remove the `Case` tab from `ContentTabsView` and route case selection inside the Stage surface.
4. Compose case-level UI inside `FullStageView` or a Stage-owned child component, reusing `TestCaseView`/view-state behavior where possible without changing persistence semantics.
5. Preserve focused step-detail routing from Stage/case/blocker flows, including return behavior to Stage.
6. Add or update context-aware empty states needed by the new route model, with stable identifiers and clear primary actions.
7. Record validation in the PR description using `Summary`, `Scope`, `Notes`, and `Validation`.
8. Split into a task branch if the work exceeds 10 changed files, mixes unrelated domains, or makes review unsafe.

Do not build automatically unless the user explicitly asks. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#10.3: Guided Navigation`
