# SPDD Steps 1-3: Tentpole Requirements

Task: plan the next FSAE Competition App work around three tentpoles: persistence, judge UX, and code organization. The first three SPDD iterations are planning-only and must not change app code.

## Essence

Define the contracts that let the app move from the current local JSON/coordinator-backed inspection flow toward a stage-first, persistable, feature-organized judge workflow without losing OpenSpec traceability.

## Acceptance Sources

- `openspec/changes/technical-inspection-event-development-plan/proposal.md`
- `openspec/changes/technical-inspection-event-development-plan/design.md`
- `openspec/changes/technical-inspection-event-development-plan/tasks.md`
- `openspec/changes/technical-inspection-event-development-plan/specs/inspection-event-execution/spec.md`
- `openspec/changes/technical-inspection-event-development-plan/specs/inspection-event-json-content/spec.md`
- `openspec/changes/technical-inspection-event-development-plan/specs/inspection-event-testing-strategy/spec.md`
- `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`
- `docs/prompts/tasks/TASK-7-session-submission-and-recheck-flow/common-instructions.md`
- `docs/prompts/tasks/TASK-10-local-stored-judge-experience-ux-follow-up/common-instructions.md`

## Existing OpenSpec Baseline

- OpenSpec currently treats bundled inspection JSON as the offline content source of truth.
- Application Support JSON persistence is the current operational storage plan: one draft file per test case, scoped by event, team, session, stage, and test case.
- `InspectionEventStore`, `TestCaseJSONPersistenceService`, and `SubmissionSnapshotService` already exist as actor-isolated service boundaries.
- TASK 7 is mostly implemented through 7.9; 7.10 rechecks, 7.11 sticker eligibility, and 7.12 manual validation remain open.
- TASK 10 already frames the UX follow-up around stable restored context, actionable blockers, derived pending state, clarified notes/evidence, metadata-first camera evidence, and egress stopwatch support.

## Tentpole 1: Persistence

User-visible or reviewer-visible outcome:

- A judge can start/resume a team inspection, edit drafts, switch teams, submit valid stages, review immutable history, and eventually close rechecks without draft leakage or lost context.

Required behavior:

- Preserve the current OpenSpec contract that draft state is scoped by `eventID + teamID + sessionID + stageID + testCaseID`.
- Preserve one-draft-per-test-case semantics when planning SwiftData/ModelActor.
- Keep submitted snapshots immutable; corrections flow through recheck/request records rather than mutating historical submissions.
- Keep UI/coordinators on the main actor and persistence/session mutation behind actor boundaries.
- Define missing domain entities before implementation: `Judge`, `Member`, `Team`, `Workspace`, `Session`, `Submission`, `Request`.

Out of scope for steps 1-3:

- Adding `@Model`, `ModelContainer`, `ModelActor`, or any SwiftData code.
- Migrating Application Support JSON files.
- Implementing rechecks, sticker eligibility, or remote sync.

Completion signal:

- A domain glossary, lifecycle map, storage contract, actor boundary sketch, ID policy, migration questions, and OpenSpec scenario mapping exist and are reviewed.

## Tentpole 2: User Experience

User-visible or reviewer-visible outcome:

- The judge's primary path becomes `Sessions -> Team -> Stage`, with Stage acting as the operational cockpit for test cases, blockers, draft state, and submission.

Required behavior:

- Treat `Case` and `Step` as internal routes or drill-ins opened from Stage, not as top-level tabs.
- Keep the `Case` tab's existing capabilities in the product contract before hiding it: ordered steps, outcome, notes, measurement, evidence, validation summary, and blocker correction.
- Stage must receive real persisted drafts, not `draftsByTestCaseID: [:]`.
- Stage submit must use real validation and snapshot creation, not `submitStage: {}`.
- Blockers must be actionable and route/focus the judge to the missing outcome, notes, measurement, or evidence control.
- Pending should be treated as derived incomplete state, not a judge decision, unless a migration contract says otherwise.

Out of scope for steps 1-3:

- Removing tabs.
- Rewriting `FullStageView`, `TestCaseView`, or `StepOverviewView`.
- Adding camera capture, stopwatch UI, or new interaction behavior.

Completion signal:

- A `Move / Keep / Hide / Discard` matrix exists for Stage, Case, and Step functionality, mapped to Gherkin and OpenSpec scenarios.

## Tentpole 3: Code Organization

Reviewer-visible outcome:

- The future folder structure is feature-oriented, but no file is moved until boundaries and validation checks are explicit.

Required behavior:

- Respect the current OpenSpec architecture of Models, Views, Coordinators, and Services.
- Define `App`, `Common`, and feature boundaries before moving files.
- Preserve build behavior and public symbols during any future move-only pass.
- Treat `InspectionModels.swift` as a high-risk split because it mixes official content, UI/mock team state, colors, legacy step models, and `MockInspectionData`.
- Preserve existing tests and OpenSpec traceability for every later movement.

Out of scope for steps 1-3:

- Moving files.
- Editing the Xcode project.
- Renaming symbols.
- Splitting validation or model files.

Completion signal:

- A dry-run table exists mapping current files to proposed destinations with imports, risk, and validation checks.

## Cross-Tentpole Rules

- The first three SPDD iterations are documentation and contract only.
- Existing user changes must not be overwritten; the worktree already has a pre-existing modification in `TestCaseJSONPersistenceService.swift`.
- No app code should be changed until the step 1-3 artifacts are reviewed.
- Every later implementation task must reference a Gherkin scenario, OpenSpec requirement, or TASK row.

# Tentpole Map

Task 12 is a planning/indexing task for the tentpole structure. It should be treated as part of Task 9 / Tentpole 3 rather than as a standalone product feature.

| Tentpole | Scope | Existing Tasks | Current Role |
| --- | --- | --- | --- |
| Tentpole 0 | Full execution flow of the technical inspection event | Tasks 5-7.9 | Existing foundation for test step, test case, stage, local session, and submission snapshot flow. |
| Tentpole 1 | Persistence | New SwiftData/ModelActor planning plus existing Task 7 storage contracts | Preserve current JSON scoping while defining the future persistence model. |
| Tentpole 2 | User experience | Task 10 plus Task 7.10-7.12 | Stage-first judge workflow, stable restored context, actionable blockers, recheck closure, sticker eligibility, full manual validation, Case/Step as internal routes. |
| Tentpole 3 | Code organization, documentation, and review hygiene | Task 9 and Task 12 | Prompt taxonomy, feature/Common boundaries, documentation standards, PR hygiene, task grouping. |
| Tentpole 4 | UI automation and snapshots | Task 8 | Dedicated UI automation, accessibility selector assertions, launch fixtures, snapshot coverage. |

## Execution Rules

1. Task 7 foundation work through 7.9 must be complete before implementation work derived from these prompts begins.
2. Task 9 / Tentpole 3 should be prioritized next because the prompt taxonomy and review structure affect every later tentpole.
3. Task 10 should be reviewed with the current context and then executed under Tentpole 2 after the Tentpole 3 structure is clear.
4. Task 8 remains a dedicated UI automation tentpole and should not be mixed into implementation PRs until navigation hooks and accessibility identifiers are stable.
5. From now on, prompts should be grouped by tentpole.
6. Each tentpole should own a `tasks/` folder for child prompt runs.
7. Task 7.10, 7.11, and 7.12 should be executed and reviewed under Tentpole 2 while retaining their original traceability IDs.
8. Task 12 should become the index task that explains where the existing Task 5-10 prompt runs fit in the tentpole structure.
