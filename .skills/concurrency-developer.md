---
name: Concurrency Developer
domain: inspection-event
status: active
owners:
  - Architect
  - Developer
  - Tester
---

# Concurrency Developer Skill

## Purpose

Guide Swift 6 concurrency work for actor isolation, async services, `Sendable` models, and safe main-actor UI boundaries in the technical inspection event workflow.

## Use When

- Implementing `InspectionContentService`, `InspectionEventStore`, `SubmissionSnapshotService`, `RecheckService`, or `AuthenticationService`.
- Passing inspection models, drafts, snapshots, or validation results across async boundaries.
- Updating SwiftUI state from async services.
- Testing concurrent session, draft, submission, or recheck behavior.

## Required Inputs

- Architect boundary note for the current feature slice.
- Service and coordinator responsibilities from `design.md`.
- Related tests from the Tester agent.
- Models that cross async boundaries.

## Implementation Checklist

- Prefer value-type models that are immutable after creation where practical.
- Mark models `Sendable` when they cross actor or task boundaries.
- Convert UI input into a single immutable `Sendable` command/value before starting a `Task` or calling an actor.
- Prefer typed command values over repeated same-type parameters for identity-sensitive input, especially when several `String` values cross from SwiftUI into coordinators or stores.
- Keep `InspectionEventStore` actor isolated for event, team, session, draft, submission, recheck, and sticker state.
- Expose async service APIs for content loading, validation, submission snapshot creation, recheck review, and mock authentication.
- Return typed errors for malformed bundled content and unsupported step types.
- Use `@MainActor` for UI-facing coordinator state or view model adapters.
- Avoid mutating SwiftUI state from detached tasks or background actor contexts.
- Keep coordinator intents small and explicit so async work can be tested.
- Validate required and impossible field combinations at the actor/service boundary so bad UI wiring fails predictably instead of corrupting persisted state.

## Expected Outputs

- Async service APIs with clear ownership and error behavior.
- Actor-isolated mutable session state.
- Main-actor handoffs for UI state updates.
- Unit tests for async success, failure, isolation, and routing behavior.
- Boundary tests that prove each field in a submitted command reaches the actor/service unchanged.

## Agent Usage

- Architect uses this skill to choose service and actor boundaries.
- Developer uses this skill while implementing Swift 6 async behavior.
- Tester uses this skill to identify async service and actor isolation tests.
