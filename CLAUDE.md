# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

An offline-first iOS (SwiftUI, Swift 6) app for conducting Formula SAE Electric Vehicle technical inspections. Judges select or resume a team session, walk through the 6 official inspection stages (Garage, Body, Chassis, EV, Egress, Rain), record Pass/Fail/N/A verdicts with notes and measurements against test cases, submit immutable stage snapshots, and track failed test cases as rechecks until sticker eligibility. All checklist content is bundled JSON — no network required.

Behavioral source of truth: `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`. Test names and PR validation notes should map back to its scenarios.

## Build and test

Xcode project: `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist.xcodeproj`
Shared scheme: `FSAEInspectionChecklist` (test target `FSAEInspectionChecklistTests`). Dedicated UI/snapshot tests are planned as a separate PR and do not yet have their own target.

```sh
cd FSAECertification/FSAEInspectionChecklist

# Build
xcodebuild build -project FSAEInspectionChecklist.xcodeproj -scheme FSAEInspectionChecklist \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Run all tests
xcodebuild test -project FSAEInspectionChecklist.xcodeproj -scheme FSAEInspectionChecklist \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Run a single test class/case (Swift Testing lives in FSAEInspectionChecklistTests)
xcodebuild test ... -only-testing:FSAEInspectionChecklistTests/InspectionCoordinatorTests
```

Note: scheme and test target names are verified from `xcodebuild -list`; the simulator destination is not pinned anywhere in the repo — use any installed iOS simulator. Unit tests use Swift Testing (`@Test`), not XCTest.

The project uses Xcode file-system-synchronized groups (`PBXFileSystemSynchronizedRootGroup`): new Swift files placed in the source tree are picked up automatically, no `project.pbxproj` edits needed.

## Architecture

MVC with Coordinators and Services (deliberately not MVVM — see `openspec/changes/technical-inspection-event-development-plan/design.md`):

- **Models** — immutable inspection content (`InspectionStage/Section/TestCase/TestStep`) plus mutable draft state (`TestCaseDraft`, `TestStepDraft`), validation, submission, and recheck value types.
- **Views** — SwiftUI value views with only local presentation state; they render coordinator-backed state.
- **Coordinators** — own navigation, flow state, and user intents: `AppCoordinator` (launch/login/root), `InspectionEventCoordinator` (active event/session), `SessionSelectionCoordinator`, `InspectionExecutionCoordinator` (stage/case/step routing, submission, team switch).
- **Services** — async boundaries: `InspectionContentService` (decodes bundled stage JSON), `InspectionValidationService`, `SubmissionSnapshotService`, and the actor-isolated `InspectionEventStore` — the single source of truth, with reads/writes scoped by event, team, session, and user access.

Source layout under `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/`:

- `App/` — entry point, `ContentView`, root tab composition and bindings.
- `Common/UI/` — design system primitives, keyboard accessory.
- `Features/` — `SessionFlow` (coordinators + store), `StageExecution`, `TestCaseExecution`, `TestStepExecution`, `InspectionContent` (content service + shared models), `Validation`, `Persistence`, `Submission`.
- `TestSupport/Fixtures/` — test fixture loaders.

### Persistence

`TestCaseJSONPersistenceService` writes one JSON file per in-progress test case under Application Support, scoped as `events/<event>/teams/<team>/sessions/<session>/drafts/<stage>/<test-case>.json`. Submitted stage snapshots are immutable, append-only records in a per-team `submissions/` folder — corrections happen through recheck records, never by mutating historical snapshots. Writes are atomic and actor-isolated; relaunch restores draft state from these files.

### Concurrency

The app target is main-actor-first by default. Domain models, JSON schema structs, and validation value types are explicitly `nonisolated` so they cross actor boundaries and satisfy `Codable`/`Sendable` synchronously. Keep persistence and validation work off the main actor; keep UI state and navigation on it.

## Conventions

- **TDD-first**: write failing Swift Testing tests with the code they prove, in the same slice/PR. UI automation and snapshot tests live in dedicated PRs, not mixed into implementation PRs.
- **Localization**: user-visible strings and accessibility labels go through structured per-file `Strings` enums — no raw literals in views (raw strings OK only for stable technical identifiers and fixtures).
- **Accessibility**: actionable controls and status indicators need stable accessibility identifiers that are constants independent of localized labels. Status must never rely on color alone.
- **Branch/PR flow**: one feature branch + one PR per feature slice, with task-sized commits (each commit a coherent task, tests included). Short-lived task branches, when needed, branch from the feature branch and are squash-merged back before review. PR descriptions use `## Summary / ## Scope / ## Notes / ## Validation` sections.
- **Behavior-neutral organization passes**: source moves must not change UX, persistence contracts, validation rules, or route semantics; pair each move with the smallest relevant build/test command.

## Agent-driven workflow

`.agents/` defines five role files — `architect.md`, `planner.md`, `developer.md`, `tester.md`, `documenter.md` — each with a purpose, required inputs, and owned workflow phases (e.g. Architect owns boundary design before a slice; Tester defines failing tests first; Planner owns branch/commit/PR sequencing). Consult the matching agent file before doing that phase's work. `.skills/` holds companion skills (accessibility, concurrency, SwiftUI, personas) that agents reference.

## Knowledge base

- `docs/README.md` — documentation index.
- `docs/system-map.md` — current system map.
- `docs/development-history.md` — how the codebase got here.
- `docs/inspection-event/` — technical overview, tutorials, review hygiene, organization plan.
- `openspec/` — change proposals, design docs, capability specs, and task lists (start at `openspec/changes/technical-inspection-event-development-plan/`).
- `.agents/` and `.skills/` — role and skill guidance for the phased workflow above.
