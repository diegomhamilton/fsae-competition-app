# TASK#12 SPDD Tentpole Planning

Task group: SPDD planning for the 2026-06-29 FSAE Competition App tentpoles.

Purpose: organize the next work around stable tentpoles before implementation resumes, while preserving OpenSpec traceability and the current Task 5-10 prompt history.

Primary prompts:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`

Status:

- Planning-only.
- No app code changes belong in Task 12.
- Task 12 is part of Task 9 / Tentpole 3 because it defines prompt taxonomy, documentation structure, and review hygiene.

## Tentpole Index

| Tentpole | Name | Included Work |
| --- | --- | --- |
| Tentpole 0 | Technical inspection execution flow | Tasks 5-7.9: test step, test case, stage content, local session, and submission snapshot foundation. |
| Tentpole 1 | Persistence | SwiftData/ModelActor planning, current Application Support JSON contract, future migration strategy. |
| Tentpole 2 | User experience | Task 10 plus Task 7.10-7.12: local stored judge UX, Stage-first workflow, actionable blockers, recheck closure, sticker eligibility, full manual validation, Case/Step internal routing. |
| Tentpole 3 | Code organization and review hygiene | Task 9 and Task 12: feature/Common boundaries, documentation standards, prompt taxonomy, PR hygiene, behavior-neutral splits for `AppCoordinators.swift` and `ContentView.swift`. |
| Tentpole 4 | UI automation and snapshots | Task 8: UI automation, accessibility selector checks, launch fixtures, snapshots, coverage documentation. |

## Execution Order

1. Confirm Task 7 foundation work through 7.9 is complete before implementation work derived from Task 12 begins.
2. Execute Tentpole 3 first to stabilize prompt taxonomy and documentation structure.
3. Review Task 10 under Tentpole 2 after the Tentpole 3 structure is clear.
4. Keep Tentpole 1 persistence planning aligned with current JSON scoping before adding SwiftData/ModelActor code.
5. Keep Tentpole 4 as a dedicated UI automation effort after stable navigation hooks and accessibility identifiers exist.

## Review Notes

- Task 12 should not mark Task 7 complete by itself.
- Task 7.10, 7.11, and 7.12 are tracked under Tentpole 2 even though they keep their original traceability IDs.
- Task 12 should not move source files or edit Xcode project settings.
- Later prompt folders should be grouped by tentpole rather than only by chronological task number.
- Existing Task 5-10 prompts remain useful history; this task provides the index that explains where they belong.
- Task 9 also owns small behavior-neutral source organization tasks when they make later implementation PRs easier to review.
