# SPDD Task Prompt Runs

Prompt runs are grouped by tentpole first and by OpenSpec macro-task second so implementation work can be planned as reviewable PR slices without losing traceability.

## Tentpole Index

| Tentpole | Scope | Prompt Folders |
| --- | --- | --- |
| Tentpole 0 | Technical inspection execution foundation: test step, test case, stage content, local session, and submission snapshot flow. | `TASK-5-test-case-slice/`, `TASK-6-test-case-list-and-stage-slice/`, `TASK-7-session-submission-and-recheck-flow/` through 7.9 |
| Tentpole 1 | Persistence planning and future SwiftData/ModelActor migration while preserving the current Application Support JSON contract. | Future persistence prompt folders, with Task 7 storage docs as baseline context |
| Tentpole 2 | Local stored judge UX: Stage-first workflow, restored context, actionable blockers, recheck closure, sticker eligibility, and manual validation. | `TASK-10-local-stored-judge-experience-ux-follow-up/`, plus original Task 7.10-7.12 traceability |
| Tentpole 3 | Code organization, documentation, prompt taxonomy, and review hygiene. | `TASK-9-documentation-and-review-hygiene/`, `TASK-12-spdd-2026-06-29-tentpoles/` |
| Tentpole 4 | Dedicated UI automation, accessibility selector assertions, launch fixtures, snapshots, and coverage documentation. | `TASK-8-dedicated-ui-test-and-snapshot-pr/` |

## Execution Notes

- Execute Tentpole 3 before more implementation-heavy work so folder boundaries, prompt taxonomy, and review hygiene are stable.
- Keep existing Task 5-10 prompt folders as history and traceability even when future prompts are grouped by tentpole.
- Each tentpole should own a `tasks/` folder for future child prompt runs when the tentpole grows beyond the current macro-task layout.
- Task 7.10, 7.11, and 7.12 should be planned and reviewed under Tentpole 2 while retaining their original OpenSpec IDs.
- App source movement belongs in behavior-neutral Task 9 organization passes only after the relevant dry-run table and validation checks are documented.

Macro-task folders:

- `TASK-5-test-case-slice/`
- `TASK-6-test-case-list-and-stage-slice/`
- `TASK-7-session-submission-and-recheck-flow/`
- `TASK-8-dedicated-ui-test-and-snapshot-pr/`
- `TASK-9-documentation-and-review-hygiene/`
- `TASK-10-local-stored-judge-experience-ux-follow-up/`
- `TASK-12-spdd-2026-06-29-tentpoles/`

Existing task prompts keep the original SPDD chain:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

For TASK#7 through TASK#10, the macro-task folders emphasize `05-operations-summary.md` because these tasks are best managed by PR operations, review scope, and common delivery instructions. Use the common-instructions file in each macro-task before opening or updating a PR.
