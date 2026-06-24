# Requirements Prompt

You are helping with SPDD for this task:

Task: `5.4 Implement InspectionValidationService rules for missing outcome, failed note requirement, invalid measurement, and missing evidence.`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible outcome for judges submitting inspection stages
- Acceptance source, especially `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature` scenarios `US-002`, `US-003`, and `US-004`
- Required validation behavior
- Deterministic validation issue codes and messages suitable for UI summaries and tests
- Out of scope behavior
- Completion signal

Keep this focused on what must be true, not how to build it.

Context:

- Branch: `codex/task-5.4-validation-service`
- Expected PR title: `TASK#5.4: Implement validation service`
- OpenSpec task: `5.4 Implement InspectionValidationService rules for missing outcome, failed note requirement, invalid measurement, and missing evidence.`
- Stage submission must be validation gated, but real submission, recheck creation, persistence, and UI refactors are out of scope.
- If a simpler `ValidationService` exists, migrate or rename carefully while preserving compatibility for existing callers and tests.
- Refactor validation so each validation issue/rule receives the immutable `InspectionTestStep` and mutable `StepResult` context and owns its validation handler, instead of duplicating each issue type's logic in separate `ValidationService` helper functions.
- Do not build automatically. The user owns build and validation unless they explicitly ask Codex to run it.
