# SPDD Steps 1-3: Tentpole Approach

Task: define the implementation shape and collaboration points for the three tentpoles without writing app code.

## Current Worktree Constraints

- Branch: `feature/task-7-validation`.
- Existing uncommitted change: `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/TestCaseJSONPersistenceService.swift`.
- No app code should be edited during SPDD steps 1-3.
- Any future implementation must preserve OpenSpec traceability and avoid overwriting user work.

## Step 1: Spec / Inventory

### Persistence Agent

Inspect and document:

- Current Application Support JSON contract.
- `InspectionEventStore` actor APIs.
- `TestCaseJSONPersistenceService` folder layout and schema version.
- `SubmissionSnapshotService` immutability contract.
- Missing entities for SwiftData/ModelActor: `Judge`, `Member`, `Team`, `Workspace`, `Session`, `Submission`, `Request`.

Output:

- Glossary and lifecycle map.
- Gap list.
- Decision list separating current JSON persistence from future SwiftData migration.

### UX Agent

Inspect and document:

- Current top-level tabs: Sessions, Team, Stage, Case, Step.
- Current capabilities of `FullStageView`, `TestCaseView`, and `StepOverviewView`.
- Existing dead placeholders: `draftsByTestCaseID: [:]`, `submitStage: {}`, mock/fallback step state.
- TASK 10 requirements around stable context, actionable blockers, pending semantics, notes/evidence labels, camera metadata, and stopwatch.

Output:

- Stage/Case/Step capability inventory.
- `Move / Keep / Hide / Discard` matrix.
- Top-level navigation contract.

### Organization Agent

Inspect and document:

- Current flat Swift source folder.
- Current test files and fixture layout.
- Files with mixed responsibilities, especially `InspectionModels.swift`.
- Large root/coordinator files, especially `AppCoordinators.swift` and `ContentView.swift`.
- Existing OpenSpec architecture language: Models, Views, Coordinators, Services.

Output:

- Feature/Common boundary proposal.
- Dry-run movement table.
- Risk and validation map for each file group.

## Step 2: Product / Flow Contracts

### Persistence Contract

- Current source of truth remains bundled official inspection JSON plus Application Support JSON draft/submission records.
- Future SwiftData/ModelActor must preserve event/team/session/stage/testCase scoping.
- Draft updates remain per-test-case transactions.
- Submitted snapshots remain immutable.
- Recheck/request records reference submissions instead of mutating them.
- UI and coordinators never own persistence directly; they call actor-isolated store/service boundaries.

Mapped scenarios:

- Start/resume session: `@US-001 @US-005 @FL-001`.
- Stage validation/submission: `@US-002 @FL-002`.
- Measurement: `@US-003 @FL-003`.
- Evidence: `@US-004 @FL-004`.
- Team switching: `@US-006 @FL-005`.
- History: `@US-007 @FL-006`.

### UX Contract

- Top-level navigation becomes `Sessions`, `Team`, `Stage`.
- `Case` and `Step` stop being top-level tabs after review, but remain internal routes.
- Stage is the operational cockpit:
  - shows stage context,
  - lists test cases,
  - displays real draft-backed progress,
  - aggregates blockers,
  - routes to first blocker,
  - submits through real validation and snapshot service.
- Case is a contextual detail/editor:
  - compact summary,
  - validation message,
  - step editor,
  - action-dominant correction flow.
- Step is optional focused detail:
  - must consume the same `TestStepDraft` as Stage/Case,
  - no mock initial values or fallback step.

### Organization Contract

- Start with contracts and docs only.
- First future movement pass should be move-only and behavior-neutral.
- Task 9 / Tentpole 3 owns behavior-neutral source splits that reduce review risk before feature work resumes.
- Prefer this reorganization order:
  1. `Common/UI` and shared identifiers.
  2. Inspection content models/services and resources.
  3. Persistence and submission services.
  4. View states and views.
  5. Split `AppCoordinators.swift` by route/coordinator ownership.
  6. Split `ContentView.swift` into root composition, tab composition, bindings, and empty states.
- Do not split `InspectionModels.swift` until tests and ownership are explicit.
- Do not reorganize `TestCaseJSONPersistenceService.swift` while the file contains unrelated user changes.

## Step 3: Technical Design Without Code

### Persistence Design

Current storage:

- Application Support JSON files remain canonical until a migration plan is approved.
- One draft file per test case.
- Immutable submitted snapshots grouped by team/session/stage/submission.

SwiftData/ModelActor evolution:

- Add an `InspectionPersistenceModelActor` only after the current JSON contract is frozen.
- Treat SwiftData as either:
  - replacement storage, with JSON import/export compatibility, or
  - index/cache over JSON audit records.
- Decision required before implementation.

Conceptual SwiftData schema:

- `InspectionWorkspace`
- `Judge`
- `Team`
- `Member`
- `InspectionSession`
- `TestCaseDraftRecord`
- `StepDraftRecord`
- `SubmissionRecord`
- `RecheckRequest`
- `StickerEligibilityRecord`

Actor boundaries:

- `InspectionContentService`: bundled content loading.
- `InspectionEventStore`: session/access/draft facade.
- `InspectionPersistenceModelActor`: future SwiftData writes/queries.
- `SubmissionSnapshotService`: immutable submissions.
- `RecheckService`: request lifecycle.
- `StickerEligibilityService`: derived eligibility.
- `@MainActor` coordinators/views: no direct `ModelContext`.

### UX Design

Navigation:

- Keep `InspectionExecutionRoute.stage/testCase/testStep`.
- Make `selectedScreen` represent only top-level tabs.
- Represent Case/Step with an internal navigation path or Stage-scoped route.

State:

- `InspectionExecutionCoordinator` should expose draft-backed `draftsByTestCaseID`.
- Edits should flow through intents:
  - `updateOutcome`
  - `updateNote`
  - `updateMeasurement`
  - `updateEvidence`
  - `openBlockingIssue`
  - `submitStage`
- Each intent eventually saves through `InspectionEventStore.saveDraft`.

Stage/Case/Step matrix:

| Capability | Decision |
| --- | --- |
| Stage list and progress | Keep in Stage |
| Test case rows | Keep in Stage |
| Stage blockers | Keep in Stage; make actionable |
| Submit stage | Keep in Stage; connect to real service |
| Case validation summary | Move into Stage row/expanded detail, keep in Case route |
| Outcome/notes/measurement/evidence editing | Move to Stage-driven correction flow; keep Case/Step as drill-ins |
| Case tab | Hide from top-level navigation |
| Step tab | Hide from top-level navigation |
| Mock step fallback | Discard |
| `draftsByTestCaseID: [:]` | Discard |
| `submitStage: {}` | Discard |
| Prototype `SC-*` copy | Replace in TASK 10 |

Open UX questions:

- Should Case open as push navigation, sheet, or split/panel?
- Should the first blocker route to Case and focus a control, or route directly to Step detail?
- Should history live under Team or Stage?
- Should recheck state appear on Case rows before TASK 7.10 is implemented?
- Is `pending` migrated from stored values or derived only after TASK 10.6?

### Organization Design

Target tree:

```text
FSAEInspectionChecklist/
  App/
    FSAEInspectionChecklistApp.swift
    ContentView.swift

  Common/
    UI/
    Accessibility/
    Localization/

  Features/
    InspectionContent/
      Models/
      Services/
      Resources/
    SessionFlow/
      Coordinators/
        AppCoordinator.swift
        AppCoordinatorRoute.swift
        InspectionEventCoordinator.swift
        SessionSelectionCoordinator.swift
        InspectionExecutionCoordinator.swift
      Models/
      Views/
      Store/
    StageExecution/
      Views/
      ViewState/
    TestCaseExecution/
      Views/
      ViewState/
      Models/
      Coordinators/
    TestStepExecution/
      Views/
      Models/
    Validation/
    Persistence/
      Models/
      Services/
    Submission/
      Models/
      Services/
    Rechecks/
    Stickers/

  TestSupport/
    Fixtures/
```

Dry-run priorities:

1. Move `DesignSystem.swift` and `KeyboardDismissBar.swift` to `Common/UI`.
2. Move content services/models only after `InspectionModels.swift` is split safely.
3. Move persistence/submission after the pre-existing `TestCaseJSONPersistenceService.swift` change is resolved.
4. Move views and view states after Stage/Case/Step navigation contract is approved.
5. Split `AppCoordinators.swift` into route enums and one file per coordinator, preserving public behavior.
6. Split `ContentView.swift` into root composition, top-level tab composition, binding helpers, and empty-state presentation, preserving current tabs until Tentpole 2 changes them.

Validation for future implementation:

- `InspectionCoordinatorTests`
- `InspectionEventStoreTests`
- `TestCaseJSONPersistenceServiceTests`
- `SubmissionSnapshotServiceTests`
- `InspectionStageContentTests`
- `FullStageViewStateTests`
- `InspectionTestCaseViewStateTests`
- manual validation for Gherkin US-001 through US-007.

## Decisions Needed Before Code

1. Is SwiftData replacing JSON or indexing/exporting JSON?
2. Does `Request` mean recheck request, submission review request, exception request, or generic workflow request?
3. Does `Workspace` belong to event, team, or judge-device context?
4. Should `Case` open as push, sheet, or inline expansion from Stage?
5. Should first blocker route to Case-level focus or Step detail?
6. Should `Pending` be persisted or derived only?
7. Which entity owns sticker eligibility: team, session, workspace, or event?
8. Should history be surfaced from Team, Stage, or both?
