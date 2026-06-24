# Structure Prompt

Given this task and approach:

Task: `5.4 Implement InspectionValidationService rules for missing outcome, failed note requirement, invalid measurement, and missing evidence.`

Approach: `<paste approach>`

Define the implementation structure.

Include:

- Models and draft state involved
- Services involved, including whether `InspectionValidationService` replaces or wraps `ValidationService`
- Validation issue/rule structure that receives `InspectionTestStep` and `StepResult` and owns the validation handler for its own rule
- Tests involved and exact rule coverage
- Dependencies between immutable step content, mutable draft state, `MeasurementValue`, evidence metadata, and validation issues
- Suggested commit boundaries
- Risks from renaming a service used by existing callers
- Risks from changing `MeasurementValue` semantics
- How this task fits into OpenSpec Test Case Slice task `5.4`

Prefer the existing MVC + Coordinators + Services architecture.

Commit rule:

Each commit title must be 52 characters or fewer and must not intentionally leave the project in a non-compiling state at commit boundaries.

Build policy:

Do not build automatically. The user owns build and validation unless they explicitly ask Codex to run it.
