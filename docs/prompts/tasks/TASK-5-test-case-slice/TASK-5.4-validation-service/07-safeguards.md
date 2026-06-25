# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `5.4 Implement InspectionValidationService rules for missing outcome, failed note requirement, invalid measurement, and missing evidence.`

Plan: `<paste operations>`

Review for:

- Scope creep beyond validation service rules and focused tests
- Missing failing tests for any required rule
- Missing deterministic issue codes or messages
- Missing localization keys or interpolation arguments for validation issues
- Accidental UI refactors or submission/recheck creation
- Breaking existing `ValidationService` callers if a rename is needed
- Measurement validation bypassing `MeasurementValue`
- Treating whitespace-only notes as valid for failed outcomes
- Treating empty evidence metadata as satisfying required evidence
- Hard-coding evidence validation so future minimum counts or media-type-specific counts cannot be added locally to the evidence rule
- JSON fixture/schema assumptions not supported by current models
- Unsafe concurrency or shared mutable state
- Accessibility or localization regressions in existing surfaces
- Commit boundaries that would knowingly break compilation
- PR title not starting with `TASK#5.4:`
- Automatic build/test execution despite the user-run build policy
- Manual validation omissions

Return blockers first, then recommendations, then a final go/no-go.

Build policy:

Do not build automatically. The user owns build and validation unless they explicitly ask Codex to run it.
