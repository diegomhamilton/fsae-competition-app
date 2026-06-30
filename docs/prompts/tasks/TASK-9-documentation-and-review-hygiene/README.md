# TASK#9 SPDD Operations Prompt Run

Task group: Tentpole 3 - Code Organization, Documentation, and Review Hygiene

Purpose: keep implementation PRs easy to review by standardizing frontmatter, technical reports, tutorials, PR descriptions, branch strategy, task-sized commits, prompt taxonomy, and small behavior-neutral organization splits.

Tentpole 3 source:

- `docs/prompts/tasks/TASK-12-spdd-2026-06-29-tentpoles/README.md`
- `docs/prompts/tasks/TASK-12-spdd-2026-06-29-tentpoles/03-approach.md`

Organization priority:

1. Document the target `App`, `Common`, `Features`, and `TestSupport` tree and dry-run movement table.
2. Move or split `Common/UI` files first, starting with `DesignSystem.swift` and `KeyboardDismissBar.swift`.
3. Defer inspection content, persistence, submission, view, and view-state moves until ownership, imports, and validation checks are explicit.
4. Split `AppCoordinators.swift` and `ContentView.swift` only after the lower-risk organization boundaries are documented.

Primary prompt:

- `05-operations-summary.md`

Shared instruction highlight:

- `common-instructions.md`

Expected branch:

`codex/inspection-event-docs-review-hygiene`

Default PR strategy:

Prefer documentation-only PRs for frontmatter, reports, tutorials, and organization dry-runs. For behavior-neutral source organization tasks, keep changes focused, move or split one ownership boundary at a time, and prove there is no behavior change with existing tests. For implementation branches, apply TASK#9.4 through TASK#9.10 as operating rules rather than mixing broad documentation rewrites, feature behavior, and source organization in one PR.

Child prompt runs:

- `TASK-9.1-documentation-frontmatter/`
- `TASK-9.2-technical-report-overview/`
- `TASK-9.3-tutorials/`
- `TASK-9.4-pr-description-template/`
- `TASK-9.5-branch-pr-hygiene/`
- `TASK-9.6-reviewable-commits/`
- `TASK-9.7-organization-dry-run/`
- `TASK-9.8-common-ui-boundary/`
- `TASK-9.9-split-app-coordinators/`
- `TASK-9.10-split-content-view/`
