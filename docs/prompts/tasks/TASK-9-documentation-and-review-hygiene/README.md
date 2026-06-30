# TASK#9 SPDD Operations Prompt Run

Task group: Documentation and Review Hygiene

Purpose: keep implementation PRs easy to review by standardizing frontmatter, technical reports, tutorials, PR descriptions, branch strategy, task-sized commits, and small behavior-neutral organization splits.

Primary prompt:

- `05-operations-summary.md`

Shared instruction highlight:

- `common-instructions.md`

Expected branch:

`codex/inspection-event-docs-review-hygiene`

Default PR strategy:

Prefer documentation-only PRs for frontmatter, reports, and tutorials. For behavior-neutral source organization tasks, keep changes focused, move or split one ownership boundary at a time, and prove there is no behavior change with existing tests. For implementation branches, apply TASK#9.4 through TASK#9.8 as operating rules rather than mixing broad documentation rewrites, feature behavior, and source organization in one PR.

Child prompt runs:

- `TASK-9.1-documentation-frontmatter/`
- `TASK-9.2-technical-report-overview/`
- `TASK-9.3-tutorials/`
- `TASK-9.4-pr-description-template/`
- `TASK-9.5-branch-pr-hygiene/`
- `TASK-9.6-reviewable-commits/`
- `TASK-9.7-split-app-coordinators/`
- `TASK-9.8-split-content-view/`
