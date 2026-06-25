# Approach Prompt

Given the requirements and entities for this task:

Task: `6.4 Refactor FullStageView to render real stage content, stage progress, validation blockers, and submit controls from model state.`

Propose an implementation approach.

Include:

- How to use JSON-backed `InspectionStage` content
- How to compose or aggregate test case draft progress
- How to use `InspectionValidationService` for blockers without duplicating validation rules
- How to keep submit controls model-driven and coordinator-ready
- How to keep SwiftUI local state small
- How to preserve skeleton layout and design-system conventions
- How to test stage progress and blocked-submit helper behavior where practical

Preferred direction:

- Extract stage summary helpers if the `FullStageView` body becomes too dense.
- Use existing test case validation and draft aggregation where possible.
- Show blocked state with text/icon or shape, not color alone.
- Route row selections and submit actions through closures or coordinator-ready intents.

Do not build automatically. Name the exact command the user can run when ready to verify the implementation.
