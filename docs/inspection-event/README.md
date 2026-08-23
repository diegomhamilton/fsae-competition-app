---
title: Inspection Event Technical Overview
domain: technical-inspection
feature: inspection-event
status: active
owners:
  - Documenter
  - Architect
source_files:
  - openspec/changes/technical-inspection-event-development-plan/design.md
  - openspec/changes/technical-inspection-event-development-plan/specs/inspection-event-execution/spec.md
  - openspec/changes/technical-inspection-event-development-plan/specs/inspection-event-json-content/spec.md
  - openspec/changes/technical-inspection-event-development-plan/specs/inspection-event-accessibility-localization/spec.md
  - openspec/changes/technical-inspection-event-development-plan/specs/inspection-event-testing-strategy/spec.md
related_scenarios:
  - Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature
---

# Inspection Event Technical Overview

## Purpose

The inspection event app is a local-first SwiftUI tool for judges who need to select a team session, inspect official technical inspection stages, record outcomes, persist draft work, submit immutable stage snapshots, and track failed test cases through recheck review. The current implementation is intentionally incremental: session selection, stage-first navigation, draft editing, validation, and local JSON draft persistence are wired into the app; stage submission, recheck review, sticker eligibility, remote services, and UI automation remain follow-up slices.

## Architecture

The app follows a Swift 6, SwiftUI, and Concurrency-first MVC shape.

Models define immutable inspection content and mutable draft state. Core values include `InspectionStage`, `InspectionSection`, `InspectionTestCase`, `InspectionTestStep`, `TestCaseDraft`, `TestStepDraft`, `ValidationIssue`, `SubmissionSnapshot`, and local persistence schema records.

Views stay as SwiftUI composition surfaces. They render coordinator-backed state and keep only local presentation state. The current judge shell exposes Sessions, Team, and Stage as top-level tabs. Test case and focused step editing are pushed inside the Stage tab rather than exposed as separate top-level destinations. User-visible strings should live in structured `Strings` enums so localization work can migrate to string catalogs later.

Coordinators own routing and user intents. `AppCoordinator` handles launch/login/root screen selection. `InspectionEventCoordinator` owns the active event and session lifecycle. `SessionSelectionCoordinator` owns roster decisions. `InspectionExecutionCoordinator` owns stage navigation, test case and test step push routes, draft save, and team-switch routing.

Services provide async boundaries. `InspectionContentService` loads bundled official stage JSON. `InspectionValidationService` validates outcomes, notes, measurement ranges, and required evidence. `InspectionEventStore` and `TestCaseJSONPersistenceService` preserve scoped local draft records. `SubmissionSnapshotService` can write immutable stage submission artifacts, but the Stage tab submit button is not wired to that service yet.

## Recheck Behavior

A submitted test case with a failed outcome is the unit that becomes a recheck. The JSON schema and submission snapshot service carry recheck-reference fields, and submitted snapshots remain immutable by design. Dedicated recheck creation, review, and closure behavior is still Task 10 continuation work rather than a screen-level flow in the current app.

Sticker eligibility is intended to derive from required submitted stages plus open recheck state. If any recheck remains open, the team is not sticker-ready. Task 10 owns the next implementation pass for recheck service behavior, sticker eligibility calculation, and the full local stored judge experience.

## Testing Approach

Swift Testing covers domain models, coordinators, services, persistence, and view helpers in the same implementation slices as the code under test. Test names and documentation should map positive, negative, and edge cases back to `inspection_event_use_cases.feature`.

Dedicated UI automation and snapshot tests belong to Task 8. The current navigation hooks are closer to the target shape after the Stage-tab refactor, but implementation PRs should still include focused unit tests plus manual validation notes until the dedicated UI target exists.

## Accessibility Conventions

Actionable controls, navigation destinations, status indicators, validation summaries, recheck indicators, and sticker eligibility indicators need stable accessibility identifiers. Identifiers must not depend on localized labels.

Status must not rely on color alone. Passed, failed, pending, blocked, energized, and recheck states need text, icon, shape, or accessibility value support in addition to color.

VoiceOver users must be able to complete login, session selection, stage inspection, validation correction, submission, team switching, and recheck review flows as those flows become screen-level features. For current screens, stable identifiers already cover the main session, stage, test case, step, validation, notes, evidence, and team-switch controls.

## Reset and Session History Validation

Map manual review to the feature scenario `Historical submissions are visible but immutable`:

1. Create a team, start a session, enter distinct progress in at least one test case, then return to the Team screen.
2. Select `Reset Active Session`, verify the confirmation explains that only in-progress draft state is cleared, and choose `Keep Session`. Reopen the stage and verify the draft remains.
3. Request reset again and choose `Reset Session`. Verify the app returns to Sessions, the team is ready to start a new session, and the prior active draft no longer restores.
4. Complete a new session, return to Sessions, and verify its read-only Past executions entry shows both Started and Ended timestamps.
5. Start and reset another in-progress session for the same team. Verify the completed Past executions entry remains unchanged.
6. Add or inspect a team with no completed session. Verify its Past executions panel says `No completed sessions yet.` and exposes no editable history controls.

The reset confirmation, cancel action, reset action, history panel, and history rows use stable accessibility identifiers. Completed history rows use a lock cue plus a VoiceOver label ending in `Read-only`; color is not used to communicate immutability.

## Localization Conventions

User-visible text and accessibility labels should be centralized through structured per-file `Strings` enums. Raw string literals are acceptable only for stable technical identifiers, fixture values, or test-only data.

When new UI text is introduced, include its visible copy, accessibility label or hint, and validation/error copy in the same localizable structure. This keeps future string catalog migration mechanical and reviewable.
