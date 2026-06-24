# Approach Prompt

Given the requirements and entities for this task:

Task: `6.2 Implement InspectionContentService as an async service that loads the six bundled inspection JSON resources.`

Propose an implementation approach.

Include:

- How to start from TASK#6.1 failing tests
- How to load bundled resources asynchronously without putting workflow logic in SwiftUI views
- How to keep model decoding deterministic and Sendable-safe
- How to surface typed errors without partial official content
- How to preserve official display order
- How to add only focused tests or update existing TASK#6.1 tests as needed
- How to avoid TASK#6.3 through TASK#6.7 scope

Preferred direction:

- Keep `InspectionContentService` in the app target under the existing inspection-content model/service area.
- Make resource loading async even if bundled files are local, so future remote or persisted sources can share a boundary.
- Return fully decoded `[InspectionStage]` only after all six official resources succeed.
- Keep JSON filename/order configuration centralized and testable.
- Preserve mock fixture loaders from earlier slices.

Do not build automatically. Name the exact command the user can run when ready to verify the implementation.
