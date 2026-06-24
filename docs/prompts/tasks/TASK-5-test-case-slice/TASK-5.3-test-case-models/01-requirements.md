# Requirements Prompt

You are helping with SPDD for this task:

Task: `5.3 Implement test case models and draft state composition from test step drafts.`

Branch: `codex/task-5.3-test-case-models`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible outcome for a judge opening a test case
- Acceptance source, especially `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`
- Required behavior
- Out of scope behavior
- Completion signal

Keep this focused on what must be true, not how to build it.

Context:

- `InspectionTestStep` and step draft/result concepts already exist in the current codebase.
- The test case must preserve ordered steps, rule references, stable IDs, and Swift model conventions.
- Progress must be derived from composed step draft state.
- Full validation service rules for missing outcomes, failed notes, invalid measurements, and missing evidence belong to TASK#5.4 unless already present.
- Expected PR title: `TASK#5.3: Implement test case models`
- Build policy: do not build automatically; user owns build unless explicitly requested.
