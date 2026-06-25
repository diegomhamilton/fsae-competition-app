# TASK#7 Operations Summary Prompt

Use this as the operation-first SPDD prompt for TASK#7 subtasks. For each row, produce a PR-ready operation plan with exact edit scope, tests, manual validation notes, commit boundary, and review risk.

| Task | PR Operation Summary | Likely Files | Validation | Split Trigger |
| --- | --- | --- | --- | --- |
| 7.1 | Add failing Swift Testing coordinator tests for login completion, session selector routing, start/resume session, stage selection, team switching, and restored context. | `FSAEInspectionChecklistTests/*CoordinatorTests.swift` | Swift Testing coordinator failures first, then pass after 7.6/7.8. | Split if coordinator fixtures or navigation helpers exceed one focused test file group. |
| 7.2 | Add failing Swift Testing persistence tests for one JSON draft file per in-progress test case under Application Support, scoped by event/team/session/stage/test case. | Persistence test files, test temp directory helpers | Swift Testing using isolated temp Application Support root. | Split if storage layout helpers become reusable infrastructure. |
| 7.3 | Define Codable JSON schemas for draft and immutable submitted snapshots with schema version, IDs, timestamps, outcomes, notes, measurements, evidence, validation, and recheck references. | Model files, schema fixtures, model tests | Codable round-trip tests and malformed payload tests. | Split if schema migration or compatibility logic grows beyond initial v1 shape. |
| 7.4 | Implement actor-isolated JSON persistence that creates folder tree, writes atomically, archives/deletes stale drafts after submission, and restores drafts on relaunch. | Persistence service, tests, file helpers | Actor-isolation tests, atomic write tests, restore tests. | Split from schemas if implementation touches more than persistence service plus tests. |
| 7.5 | Group each team's submission files in team-specific Application Support folders for submitted snapshots, rechecks, and sticker eligibility review. | Persistence layout, submission paths, tests | Path scoping tests proving no team mixing. | Split if submission path policy affects recheck and sticker services at the same time. |
| 7.6 | Implement `AppCoordinator`, `InspectionEventCoordinator`, `SessionSelectionCoordinator`, and `InspectionExecutionCoordinator`, preferably as separate task PRs or task branches. | Coordinator source files, coordinator tests | Tests from 7.1 pass by coordinator scope. | Always split if all four coordinators push the PR over 10 files or one reviewer cannot inspect flow safely. |
| 7.7 | Implement `InspectionEventStore` as actor-isolated source of truth with scoped queries by event, team, session, user access, and persistence service. | Store service, store tests, query models | Store query tests, access scoping tests, async mutation tests. | Split from coordinators if store APIs are still changing. |
| 7.8 | Bind session, dashboard, stage, step overview, and team switch views to coordinator-backed state. | SwiftUI views, coordinators, previews/tests | UI-facing unit/view helper tests plus manual smoke notes. | Split if more than two view files and two coordinator files change together. |
| 7.9 | Implement `SubmissionSnapshotService` for immutable stage submission snapshots backed by team submission JSON folders. | Submission service, models, tests | Snapshot creation tests and immutability tests. | Split if persistence cleanup or recheck creation gets mixed in. |
| 7.10 | Implement `RecheckService` so failed test cases create open recheck items and accepted reviews close them. | Recheck service, recheck models, tests | Failed case creates open item; accepted review closes item. | Split if UI review flow is introduced with service behavior. |
| 7.11 | Implement sticker eligibility from submitted stages and open rechecks. | Eligibility service/model, tests | Eligibility matrix tests for submitted/missing/open-recheck states. | Split if eligibility display UI changes are included. |
| 7.12 | Manually validate start, restore after relaunch, submit, blocked submit, team switch, recheck, sticker eligibility, per-test-case JSON files, and team folders against the feature file. | Checklist, PR validation note | User-run app evidence only. | Keep as documentation/validation PR if implementation evidence is not available. |

Common PR summary language:

```md
## Summary

Implements the next operation in the local session, submission, and recheck flow while preserving event/team/session scoping and per-test-case JSON draft persistence.

## Scope

- <Task-specific models/services/coordinators/views/tests>
- <Application Support JSON path or coordinator route affected>
- <Feature scenarios covered>

## Notes

- Uses actor-isolated persistence or store APIs where mutable local state is involved.
- Keeps submitted snapshots immutable; corrections flow through rechecks.
- Splits follow-up branches if this PR crosses more than 10 files or mixes unrelated review contexts.

## Validation

- `<test command or user-run app validation>`
- <Manual notes mapped to feature scenarios when relevant>
```
