---
title: Inspection Event Organization Plan
domain: technical-inspection
feature: inspection-event
status: active
owners:
  - Architect
  - Planner
source_files:
  - docs/prompts/tasks/TASK-12-spdd-2026-06-29-tentpoles/03-approach.md
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklistTests
related_scenarios:
  - Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature
---

# Inspection Event Organization Plan

## Target Tree

```text
FSAEInspectionChecklist/
  App/
    FSAEInspectionChecklistApp.swift
    ContentView.swift
    ContentTabsView.swift
    ContentViewBindings.swift
    EmptyFlowState.swift
    ProposedScreen.swift

  Common/
    UI/
      DesignSystem.swift
      KeyboardDismissBar.swift
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
        InspectionSessionContext.swift
        SessionSelectionCoordinator.swift
        InspectionExecutionCoordinator.swift
        InspectionEventStore+AppFactory.swift
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

## Dry-Run Movement Table

| Current file or group | Proposed destination | Import risk | Ownership risk | Validation check |
| --- | --- | --- | --- | --- |
| `DesignSystem.swift` | `Common/UI/DesignSystem.swift` | Low; SwiftUI only and project uses file-system-synchronized groups. | Low; shared UI primitives remain app-wide. | Build app target and inspect views using `ScreenShell`, `ContentPanel`, `StatusPill`, `MetricTile`, and `measurementKeyboard`. |
| `KeyboardDismissBar.swift` | `Common/UI/KeyboardDismissBar.swift` | Low; SwiftUI only. | Low; shared keyboard accessory remains UI infrastructure. | Build app target and run tests that touch `TestCaseView` or `StepOverviewView`. |
| `AppCoordinators.swift` route enums | `Features/SessionFlow/Coordinators/*Route*.swift` | Low if declarations stay internal and names do not change. | Medium; routes are referenced by tests and views. | Run `InspectionCoordinatorTests`. |
| `AppCoordinators.swift` app/event/session/execution coordinators | `Features/SessionFlow/Coordinators/` | Medium; split must preserve actor annotations and private helper scope. | Medium; session lifecycle and routing behavior are tightly coupled. | Run `InspectionCoordinatorTests` and app build. |
| `ContentView.swift` root composition | `App/ContentView.swift`, `App/ContentTabsView.swift`, `App/ContentViewBindings.swift`, `App/EmptyFlowState.swift`, `App/ProposedScreen.swift` | Medium; private helpers may need extension access instead of file-private declarations. | Medium; top-level Sessions, Team, and Stage behavior must stay stable while case and step routes remain inside Stage. | Build app target and manually smoke Sessions, Team, Stage, stage-to-case, and case-to-step navigation. |
| `InspectionModels.swift` | `Features/InspectionContent/Models/` and feature model folders | High; broad model ownership is mixed. | High; content, draft, validation, and submission models are coupled. | Defer until tests and ownership are explicit. |
| `InspectionContentService.swift` and bundled resources | `Features/InspectionContent/Services/` and `Features/InspectionContent/Resources/` | Medium; bundled resource lookup must be rechecked after folder movement. | Medium; official content is the offline source of truth. | Run content service tests and load all six bundled stages. |
| `TestCaseJSONPersistenceService.swift` | `Features/Persistence/Services/` | High while persistence work is active. | High; local draft/submission contracts must not churn casually. | Defer until current JSON contract and user changes are stable; run persistence tests. |
| `SubmissionSnapshotService.swift` | `Features/Submission/Services/` | Medium; depends on persistence schema and validation summaries. | Medium; immutable submission behavior must remain unchanged. | Run submission snapshot tests. |
| Stage, case, and step views | `Features/StageExecution`, `Features/TestCaseExecution`, `Features/TestStepExecution` | Medium; view helper and `Strings` enum access must stay local. | Medium; Task 10 may change UX ownership. | Defer until Stage-first UX decisions are settled. |
| Test fixtures | `TestSupport/Fixtures/` | Medium; test bundle resource paths can break. | Low; fixtures are test-owned. | Run affected decoding and persistence tests. |

## Applied Organization Pass

The first organization pass applied the low- and medium-risk source moves while preserving declarations, access control, and runtime behavior.

Applied:

- `App/`: app entry point and root content composition.
- `Common/UI/`: shared design primitives and keyboard accessory.
- `Features/SessionFlow/`: coordinators, session views, and inspection event store.
- `Features/StageExecution/`: stage views and view state.
- `Features/TestCaseExecution/`: test case view, coordinator, models, and view state.
- `Features/TestStepExecution/`: step overview view and step models.
- `Features/InspectionContent/`: content service and current shared inspection models.
- `Features/Validation/`, `Features/Persistence/`, and `Features/Submission/`: validation, draft persistence, and submission services.
- `TestSupport/Fixtures/`: test fixture loader support.

Deferred:

- Move bundled JSON resource directories only after resource lookup is validated against the new subdirectory layout.
- Split `InspectionModels.swift` internally only after model ownership is made explicit in tests and feature tasks.
- Add `Resources/`, `Accessibility/`, `Localization/`, `Rechecks/`, and `Stickers/` folders when concrete files exist for those owners.

## Organization Rules

Move one ownership boundary at a time. A behavior-neutral organization PR should not introduce UX changes, persistence changes, new validation rules, or route semantics.

Start with `Common/UI` because it has the lowest ownership risk. Split `AppCoordinators.swift` and `ContentView.swift` only after the target tree and dry-run table are in place.

Keep future organization passes behavior-neutral and pair each move with the smallest relevant build or test command.
