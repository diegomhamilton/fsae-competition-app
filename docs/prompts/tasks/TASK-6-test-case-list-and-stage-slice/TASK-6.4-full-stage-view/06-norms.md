# Norms Prompt

Apply the project norms to this task:

Task: `6.4 Refactor FullStageView to render real stage content, stage progress, validation blockers, and submit controls from model state.`

Check the proposed work against these norms:

- SwiftUI views with small local UI state only
- Reuse existing design system and skeleton patterns
- TDD for extracted view helpers and validation summary helpers
- Validation rules stay in `InspectionValidationService`
- Submit controls are model-driven and coordinator-ready
- `FullStageView` should not be massive, specific logics or components should have its own file
- Feature scenarios as acceptance backbone
- Status and blocked-submit states must not rely on color alone
- Strings/accessibility cleanup belongs to TASK#6.6 unless new code needs local constants immediately
- Branch name is `codex/task-6.4-full-stage-view`
- PR titles must start with `TASK#{TASK NUMBER}:`, using `TASK#6.4: Refactor full stage view`
- Commit titles must be 52 characters or fewer
- Do not build automatically; capture build and validation as user-run unless explicitly asked

Return any adjustments needed before implementation.

Expected PR title:

`TASK#6.4: Refactor full stage view`

Recommended commit title candidates:

- `Add TASK#6.4 prompt run`
- `Refactor full stage view`
- `Bind stage view to models`
