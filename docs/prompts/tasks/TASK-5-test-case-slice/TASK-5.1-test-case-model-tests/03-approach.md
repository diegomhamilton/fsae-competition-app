# Approach Prompt

Given this task and entities:

Task: `5.1 Add failing unit tests for InspectionTestCase, ordered steps, rule references, draft aggregation, blocker counts, and test case progress.`

Entities: `<paste entity summary>`

Propose a high-level implementation approach.

Include:

- Files or areas likely affected
- Test-first strategy
- Existing Swift Testing patterns to follow
- How the tests should reference current step models without implementing production test case behavior
- Swift 6 and Concurrency considerations
- Accessibility and localization considerations, if any are relevant to test case progress or blockers
- Manual validation path

Required test coverage:

- `InspectionTestCase` preserves stable ID, title, display order, and rule references.
- Ordered steps are exposed in display order even when fixture input is not ordered.
- Draft aggregation reads child `TestStepDraft` outcomes, notes, measurements, and evidence.
- Blocker counts include missing required outcomes, failed outcomes missing notes, invalid measurements, and missing required evidence.
- Test case progress distinguishes complete steps from blocked or pending steps.
- Test names or comments map back to `.feature` scenarios for opening a test case from a stage, blocked submission, failed notes, valid/invalid measurement, and evidence attach/remove behavior.

Constraints:

- Write Swift Testing unit tests only.
- Focus write scope after the prompt commit on test target files only unless a tiny test helper fixture is necessary.
- Do not add mock JSON fixtures for TASK#5.2.
- Do not implement production `InspectionTestCase`, `TestCaseDraft`, or `InspectionValidationService` behavior.
- Do not update the OpenSpec TASK#5.1 checkbox until the requested test work is actually complete.
- Do not build automatically. The user owns build and validation unless explicitly requested.
