# Operations Prompt

Given this task, approach, and structure:

Task: `5.4 Implement InspectionValidationService rules for missing outcome, failed note requirement, invalid measurement, and missing evidence.`

Structure: `<paste structure>`

Decompose this into concrete, reviewable operations.

For each operation, include:

- Exact action
- Expected files or test targets
- Verification command or manual check
- Build ownership: user-run
- Manual validation notes to capture when the user builds or inspects locally
- Commit boundary and proposed commit title of 52 characters or fewer
- Whether the operation can be committed without breaking compilation
- Done condition

Required operation coverage:

- Read current validation service, draft models, `InspectionTestStepModels.swift`, and related tests.
- Add focused Swift Testing unit tests for missing required outcome.
- Add focused Swift Testing unit tests for failed outcome requiring a non-whitespace note.
- Add focused Swift Testing unit tests for missing or invalid measurement input using `MeasurementValue`, including non-numeric format, precision exceeded, and outside valid range where supported by existing models.
- Add focused Swift Testing unit tests for missing required evidence metadata.
- Implement or update `InspectionValidationService` with deterministic issue codes and messages.
- Refactor validation around issue/rule definitions that receive `InspectionTestStep` and `StepResult` and run their own validation handlers, so the service iterates rules rather than maintaining separate duplicated helper functions per issue type.
- Preserve compatibility for existing callers or tests if a simpler `ValidationService` exists.
- Keep real submission/recheck creation out of scope.
- Update the OpenSpec task checkbox only after service rules and tests are complete.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#5.4: Implement validation service`

Commit title candidates, each 52 characters or fewer:

- `Add validation service tests`
- `Implement inspection validation rules`
- `Mark TASK#5.4 complete`
