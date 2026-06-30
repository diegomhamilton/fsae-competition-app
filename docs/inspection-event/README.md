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

The inspection event app is a local-first SwiftUI tool for judges who need to select a team session, inspect official technical inspection stages, record outcomes, persist draft work, submit immutable stage snapshots, and track failed test cases through recheck review. The current implementation is intentionally incremental: stable domain models and local JSON contracts come before broader UX changes, remote services, or UI automation.

## Architecture

The app follows a Swift 6, SwiftUI, and Concurrency-first MVC shape.

Models define immutable inspection content and mutable draft state. Core values include `InspectionStage`, `InspectionSection`, `InspectionTestCase`, `InspectionTestStep`, `TestCaseDraft`, `TestStepDraft`, `ValidationIssue`, `SubmissionSnapshot`, and local persistence schema records.

Views stay as SwiftUI composition surfaces. They render coordinator-backed state and keep only local presentation state. User-visible strings should live in structured `Strings` enums so localization work can migrate to string catalogs later.

Coordinators own routing and user intents. `AppCoordinator` handles launch/login/root screen selection. `InspectionEventCoordinator` owns the active event and session lifecycle. `SessionSelectionCoordinator` owns roster decisions. `InspectionExecutionCoordinator` owns stage, test case, test step, draft save, and team-switch routing.

Services provide async boundaries. `InspectionContentService` loads bundled official stage JSON. `InspectionValidationService` validates outcomes, notes, measurement ranges, and required evidence. `InspectionEventStore` and `TestCaseJSONPersistenceService` preserve scoped local draft and submission records. `SubmissionSnapshotService` writes immutable stage submission artifacts.

## Recheck Behavior

A submitted test case with a failed outcome is the unit that becomes a recheck. Recheck records reference the event, team, session, stage, test case, failed rules, and judge notes. Submitted snapshots remain immutable; corrections are represented by later recheck review records rather than mutation of historical submission JSON.

Sticker eligibility is derived from required submitted stages plus open recheck state. If any recheck remains open, the team is not sticker-ready. Task 10 owns the next implementation pass for recheck service behavior, sticker eligibility calculation, and the full local stored judge experience.

## Testing Approach

Swift Testing covers domain models, coordinators, services, persistence, and view helpers in the same implementation slices as the code under test. Test names and documentation should map positive, negative, and edge cases back to `inspection_event_use_cases.feature`.

Dedicated UI automation and snapshot tests belong to Task 8, after stable navigation hooks and accessibility identifiers exist. Until then, implementation PRs should include focused unit tests plus manual validation notes.

## Accessibility Conventions

Actionable controls, navigation destinations, status indicators, validation summaries, recheck indicators, and sticker eligibility indicators need stable accessibility identifiers. Identifiers must not depend on localized labels.

Status must not rely on color alone. Passed, failed, pending, blocked, energized, and recheck states need text, icon, shape, or accessibility value support in addition to color.

VoiceOver users must be able to complete login, session selection, stage inspection, validation correction, submission, team switching, and recheck review flows.

## Localization Conventions

User-visible text and accessibility labels should be centralized through structured per-file `Strings` enums. Raw string literals are acceptable only for stable technical identifiers, fixture values, or test-only data.

When new UI text is introduced, include its visible copy, accessibility label or hint, and validation/error copy in the same localizable structure. This keeps future string catalog migration mechanical and reviewable.

