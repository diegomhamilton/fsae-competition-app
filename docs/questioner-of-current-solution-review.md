# QuestionerOfCurrentSolution Review

Reviewer agent: `QuestionerOfCurrentSolution`

## Verdict

The proposed direction is sound: most warnings are caused by pure value models and helper witnesses becoming implicitly MainActor-isolated under default isolation. Actors and services such as `InspectionEventStore`, `TestCaseJSONPersistenceService`, validation, JSON decoding, and content loading should stay off MainActor.

## Risks And Impacts

- Applying `nonisolated` too broadly can bless code that is only accidentally pure today. Each declaration must be checked for immutable value-only dependencies before annotation.
- Codable, Hashable, and helper witnesses in `InspectionTestCaseModels.swift`, `InspectionTestStepModels.swift`, and `ValidationService.swift` should be nonisolated only if they touch Sendable values and pure Foundation operations.
- Moving `Color` and symbol concerns out of domain models is architecturally correct, but may require view updates for callers such as `step.type.color`, `outcome.color`, or badge presentation helpers.
- `PersistedValidationIssue.init(issue:)` should not be MainActor-isolated; keeping it isolated would pull persistence work toward the UI executor without a UI reason.

## Alternatives Worth Considering

- Add UI-facing presentation adapters or extensions for `InspectionTestStepType`, `InspectionOutcome`, and safety badge display concerns.
- Keep domain models focused on semantic values: enum cases, labels, storage codes, localization keys, and localization arguments.
- If content loading has non-Sendable dependencies such as `Bundle`, constrain those dependencies inside service methods or a small service boundary rather than relying on broad unchecked sendability.
- Longer term, consider persisting `ValidationIssue.Code`, localization key, and arguments while generating display messages at the presentation edge.

## Changes To Avoid

- Do not mark persistence, validation, JSON decoding, content loading, or actor stores as `@MainActor` just to remove warnings.
- Do not use `@preconcurrency`, `@unchecked Sendable`, or global actor annotations as blanket suppressions.
- Do not keep SwiftUI `Color` as part of Sendable domain state.
- Do not replace actors with classes and locks for this cleanup.

## Verification Requirements

- Build with strict concurrency or Swift 6 language mode and require zero warnings.
- Keep or add non-MainActor decoding/encoding tests for `InspectionTestCase`, `InspectionTestStep`, `InspectionTestStepType`, and `InspectionSafetyBadge`.
- Add concurrent validation tests that confirm deterministic issue ordering.
- Keep actor stress tests for concurrent draft saves and session isolation through `InspectionEventStore` and `TestCaseJSONPersistenceService`.
- Add a compile-time smoke path where persistence maps `ValidationIssue` to `PersistedValidationIssue` inside the persistence actor without crossing MainActor.
- Run Thread Sanitizer on persistence and store tests when available.

## Applied Solution Review - 2026-07-05

Verdict: accept with caveats.

- No actor-boundary cheating was found in the applied diff. `StepResult` remains a value snapshot while `InMemoryDraftStore` remains `@MainActor`; `SessionKey` is pure actor-internal keying while `InspectionEventStore` remains an actor; persistence DTO mapping and validation helpers are value-only.
- Codable changes preserve keys/defaults, and the saved build/test logs cover JSON decoding, validation ordering, persistence, sessions, and coordinator flows.
- Caveat: UI/domain separation is improved but still porous. `InspectionTestStepType.color` and `InspectionOutcome.color` moved out of the domain model file, but they remain global SwiftUI extensions on domain enums in the design system. Older mock/session UI models in `InspectionModels.swift` still import SwiftUI and retain color-bearing enums/palette.
- Caveat: verification supports zero Swift concurrency warnings for the recorded scheme/destination under the project’s current Swift 5 migration settings with default MainActor isolation and upcoming concurrency features. It is not a separate Swift 6 language-mode build.
