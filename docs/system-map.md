---
title: System Map — Judge Inspection Flow
domain: inspection-event
status: active
owners: [documenter-agent]
doc_hooks:
  upstream:
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/App/FSAEInspectionChecklistApp.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/App/ContentView.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/App/ContentTabsView.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/App/ContentViewBindings.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/App/ProposedScreen.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Coordinators/InspectionSessionContext.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Coordinators/AppCoordinator.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Coordinators/AppCoordinatorRoute.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Coordinators/InspectionEventCoordinator.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Coordinators/SessionSelectionCoordinator.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Coordinators/InspectionExecutionCoordinator.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Coordinators/InspectionExecutionRoute.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Store/InspectionEventStore.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Views/SessionSelectorView.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Views/ActiveTeamDashboardView.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Views/TeamSwitchConfirmationView.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/StageExecution/ViewState/FullStageViewState.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/StageExecution/Views/FullStageView.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/TestCaseExecution/Views/TestCaseView.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/TestStepExecution/Views/StepOverviewView.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/Persistence/Services/TestCaseJSONPersistenceService.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/Submission/Services/SubmissionSnapshotService.swift
    - openspec/changes/technical-inspection-event-development-plan/design.md
  downstream:
    - docs/README.md
    - CLAUDE.md
---

# System Map: Judge Inspection Flow

This document maps the judge-facing inspection journey first, then summarizes the
SwiftUI coordinator, navigation, persistence, and validation wiring that supports it. App source root:
`FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/` (all
repo-relative paths below are relative to this root unless prefixed).

## User Flow Overview

A judge launches the app, selects or resumes a team session, reviews the active
team dashboard, works through inspection stages, records test-step outcomes,
resolves validation blockers, and submits stage snapshots. During an event, the
judge can switch teams and return to the same flow for the next active session.

Primary path:

1. Launch app.
2. Select or resume a team session.
3. Review team progress and open a stage.
4. Open an inspection stage.
5. Push into a test case inside the Stage tab.
6. Record step outcomes, measurements, evidence, and notes inline, or push into a focused step detail.
7. Resolve blockers until the stage can be submitted.
8. Submit the stage snapshot.
9. Continue another stage or switch teams.

## Judge Flow Diagram

```mermaid
flowchart TD
    Launch["Open app"] --> Sessions["Choose team"]
    Sessions --> Dashboard["Review team dashboard"]
    Dashboard --> Stage["Stage tab: FullStageView"]
    Stage --> Case["Push test case"]
    Case --> Inline["Edit carousel step cards"]
    Case --> Detail["Push focused step detail"]
    Inline --> Draft["Autosave test-case draft JSON"]
    Detail --> Draft
    Draft --> Case
    Detail --> Case
    Case --> Stage
    Stage --> Blockers{"Stage blockers?"}
    Blockers -->|"Deep-link blocker"| Detail
    Blockers -->|"Ready to submit"| Submit["Submit stage"]
    Submit --> Dashboard
    Dashboard --> Switch["Switch team"]
    Switch --> Sessions
```

## Screen Responsibilities

| User goal | Screen | What the judge can do |
| --- | --- | --- |
| Pick inspection work | SessionSelectorView (Sessions tab) | Select or resume a team session; blocked teams stay on the roster. |
| Understand team progress | ActiveTeamDashboardView (Team tab) | Review stage status, open blockers, continue a stage, or start team switching. |
| Work a stage | FullStageView (Stage tab root) | Open test cases, review validation blockers, and see the validation-gated Submit Stage control. |
| Complete a case | TestCaseView (pushed inside Stage tab) | Edit all step outcomes, notes, measurements, and evidence for a test case through horizontally paged step cards. |
| Focus one step | StepOverviewView (pushed inside Stage tab) | Record a single step result, then return to the active test case. |
| Switch active team | TeamSwitchConfirmationView (sheet) | Confirm save-and-switch or cancel back to the dashboard. |

## Current Gaps

- `FullStageView` renders a **Submit Stage** button gated by draft-backed
  validation (`FullStageViewState.canSubmit`), but the `submitStage` closure wired
  in `ContentTabsView` is currently an empty no-op.
- `SubmissionSnapshotService` can create immutable stage/test-case snapshot files,
  but it is not connected to the Stage tab submit action yet.
- Recheck and sticker eligibility screens are specified in
  `openspec/changes/technical-inspection-event-development-plan/design.md` but are
  not implemented in navigation yet.
- Validation is not a separate screen: it renders inline as
  `FullStageValidationPanel` and `TestCaseValidationSummaryPanel`, then deep-links
  blockers to the relevant step.
- Test case cards currently autosave inline draft changes, but the focused step
  detail still owns a separate notes/evidence surface. Keep both paths in sync when
  changing draft semantics or accessibility identifiers.

## Implementation Map

The app is a single-window SwiftUI app (`FSAEInspectionChecklistApp` ->
`ContentView`) whose root UI is a three-tab `TabView` (`ContentTabsView`):
**Sessions**, **Team**, **Stage**. Sessions and Team are top-level
`NavigationStack`s. The Stage tab owns the in-inspection push stack:
`FullStageView` -> `TestCaseView` -> `StepOverviewView` through
`InspectionExecutionCoordinator.stageNavigationPath`.

Navigation is owned by a three-level coordinator hierarchy (MVC + Coordinators,
per the development plan design):

1. **`AppCoordinator`** (root) holds `route: AppCoordinatorRoute` (`.login` /
   `.sessionSelector` / `.inspection`) and `selectedScreen: ProposedScreen`.
   In the current UI, only the top-level landmarks
   (`.sessionSelector`, `.dashboard`, `.stageChecklist`) select visible tabs.
   Test case and step routes stay inside the Stage tab navigation path.
   `selectedScreen` is bound to the `TabView` selection via
   `ContentViewBindings.selectedScreenBinding`, so setting it changes the visible
   screen. Login is mocked: `ContentView.task` calls `completeMockLogin()` on
   launch and then loads official stages through `InspectionContentService`,
   falling back to `MockInspectionData`.
2. **`InspectionEventCoordinator`** scopes the inspection event: it owns a
   `SessionSelectionCoordinator` and creates a fresh
   **`InspectionExecutionCoordinator`** whenever a session is started or resumed,
   restoring persisted drafts from the `InspectionEventStore`.
3. **`InspectionExecutionCoordinator`** holds the in-session position as
   `stageNavigationPath: [StageNavigationRoute]`, plus team-switch state
   (`pendingSwitchTarget`) and draft state grouped by stage
   (`draftsByStageID`). Views call closures that funnel into `AppCoordinator`
   methods such as `openStage`, `openTestCase`, `openTestStep`, `saveStepDraft`,
   and `requestTeamSwitch`.

State-driven presentation: tabs whose coordinator state is missing (no execution
coordinator or no active stage) render an `EmptyFlowState` placeholder instead of
their screen. The team-switch confirmation is the one modal in the app: a
`.sheet` on `ContentView` whose `isPresented` binding derives from the execution
coordinator's pending switch target (`ContentViewBindings.teamSwitchConfirmationBinding`,
medium detent).

Persistence is local and test-case scoped. `InspectionExecutionCoordinator` loads
draft files for the active stage through `InspectionEventStore`, saves each edited
`TestStepDraft` into a `TestCaseDraft`, and delegates JSON storage to
`TestCaseJSONPersistenceService`. `SubmissionSnapshotService` can materialize
submitted test-case and stage snapshot files, but no screen currently calls it.

## Screen Inventory

| Screen | Owning coordinator | Source file (repo-relative) | Purpose |
| --- | --- | --- | --- |
| ContentTabsView (root tabs) | `AppCoordinator` | `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/App/ContentTabsView.swift` | Root three-tab `TabView`; binds top-level tab selection to `AppCoordinator.selectedScreen` and hosts Stage tab push navigation. |
| SessionSelectorView (SC-001) | `SessionSelectionCoordinator` | `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Views/SessionSelectorView.swift` | Judge-facing team roster with resume status; tapping a team starts or resumes its inspection session. |
| ActiveTeamDashboardView (SC-002) | `InspectionExecutionCoordinator` | `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Views/ActiveTeamDashboardView.swift` | Active team context: overall progress, open blockers, draft-backed per-stage status rows, open-stage and switch-team actions. |
| FullStageView (SC-003 Stage) | `InspectionExecutionCoordinator` (via `AppCoordinator` closures) | `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/StageExecution/Views/FullStageView.swift` | Ordered sections and test cases for the active stage, stage validation panel with blocker deep-links, and the validation-gated Submit Stage control. |
| TestCaseView (SC-003 Test Case) | `InspectionExecutionCoordinator` (via `AppCoordinator` closures) | `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/TestCaseExecution/Views/TestCaseView.swift` | Pushed from `FullStageView`; all steps of the active test case render as editable carousel cards with outcome, notes, measurement, evidence, and validation summary; autosaves drafts per edit. |
| StepOverviewView (SC-004/005/006) | `InspectionExecutionCoordinator` | `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/TestStepExecution/Views/StepOverviewView.swift` | Pushed from `TestCaseView` or blocker deep-link; single-step detail with outcome picker, measurement input with range help, notes editor, evidence metadata, and Done back to the active test case. |
| TeamSwitchConfirmationView (SC-007) | `InspectionExecutionCoordinator` | `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Views/TeamSwitchConfirmationView.swift` | Sheet confirming save-and-switch to another team when a session is active; Cancel returns to the dashboard route. |

Supporting (non-screen) navigation files: `App/ContentView.swift` (root view,
mock login, content loading, switch sheet host), `App/ContentViewBindings.swift`
(SwiftUI bindings bridging coordinator state to `TabView`/sheet),
`App/ProposedScreen.swift`, `Features/SessionFlow/Coordinators/AppCoordinatorRoute.swift`,
`Features/SessionFlow/Coordinators/InspectionExecutionRoute.swift`, and
`Features/SessionFlow/Coordinators/InspectionSessionContext.swift`.

## Module Inventory

| Module/file | Responsibility |
| --- | --- |
| `App/FSAEInspectionChecklistApp.swift` | SwiftUI app entry point. |
| `App/ContentView.swift` | Root composition, mock login, bundled content loading, team-switch sheet host. |
| `App/ContentTabsView.swift` | Sessions/Team/Stage tab composition and Stage tab navigation destinations. |
| `App/ContentViewBindings.swift` | Derived bindings from coordinator state into `TabView` and sheet presentation. |
| `Features/InspectionContent/Models/InspectionModels.swift` | Official event, team, stage, section, rule reference, and design-system model helpers. |
| `Features/InspectionContent/Services/InspectionContentService.swift` | Async bundled JSON loading for the six official inspection stages. |
| `Features/SessionFlow/Coordinators/*.swift` | Login/session/stage/test-case/test-step/team-switch routing and state restoration. |
| `Features/SessionFlow/Store/InspectionEventStore.swift` | Actor-backed session registry, access checks, draft listing, and draft saves. |
| `Features/SessionFlow/Views/*.swift` | Session selection, active team dashboard, and team-switch confirmation surfaces. |
| `Features/StageExecution/ViewState/*.swift` | Stage-level progress, validation, blocker routes, and dashboard view state. |
| `Features/StageExecution/Views/FullStageView.swift` | Stage root UI with section rows, validation panel, blocker deep-links, and submit affordance. |
| `Features/TestCaseExecution/*` | Test-case model, view state, coordinator, and carousel-based editable test-case screen. |
| `Features/TestStepExecution/*` | Test-step model helpers and focused single-step editing screen. |
| `Features/Validation/ValidationService.swift` | Outcome, failed-note, measurement, and evidence requirement validation rules. |
| `Features/Persistence/*` | Local JSON draft/submission schema and file persistence service. |
| `Features/Submission/Services/SubmissionSnapshotService.swift` | Immutable submitted stage/test-case snapshot creation service. |
| `Common/UI/*` | Reusable design system, panels, pills, backgrounds, keyboard dismissal, and input modifiers. |

## Risk Map

1. **Submit action is UI-only.** `FullStageView` gates Submit Stage correctly, but
   `ContentTabsView` wires `submitStage: {}`; snapshot persistence is available
   but disconnected from the judge flow.
2. **Inline case and focused step editors duplicate draft-editing surfaces.**
   `TestCaseView` and `StepOverviewView` both write outcomes, notes,
   measurements, and evidence metadata. Future changes must preserve identical
   validation and persistence semantics across both.
3. **Test-case row has fragile UI code around the step-open affordance.**
   `TestCaseStepCard` owns an `openStepDetail` closure and accessibility
   identifier for opening a step, but the current source should be rechecked for a
   visible `Button` label after M10 layout edits.
4. **Actor-isolation warnings remain known technical debt.** Several model and
   validation conformances cross main-actor-isolated helpers. Treat Swift 6
   warning cleanup as separate from UI polish PRs.
5. **Rechecks and sticker eligibility are still design-only in navigation.**
   Drafts and submission snapshots include reference fields, but no dedicated
   recheck/sticker screens or services are wired into the active flow.
