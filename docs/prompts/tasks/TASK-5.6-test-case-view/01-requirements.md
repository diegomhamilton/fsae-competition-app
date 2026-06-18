# Requirements Prompt

You are helping with SPDD for this task:

Task: `5.6 Refactor the existing stage step card pattern into a test case view that renders ordered steps and validation summaries.`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible outcome for a judge reviewing a test case
- Acceptance source, especially OpenSpec proposal/design/tasks/specs and `.feature` scenarios
- Required behavior
- Out of scope behavior
- Completion signal

Keep this focused on what must be true, not how to build it.

Context:

- Work on branch `codex/task-5.6-test-case-view`.
- Expected PR title is `TASK#5.6: Add test case view`.
- Reuse the visual language from `FullStageView` and `StageChecklistView`.
- Refactor the existing stage step card pattern into a dedicated Test Case view.
- Render ordered test steps and validation summaries from mock JSON/model state.
- Keep one keyboard dismissal affordance for repeated note inputs, preserving TASK#5.0 behavior.
- Do not implement bundled stage loading; that belongs to task 6.x.
- Do not add UI tests; a dedicated PR will cover them later.
- Do not build automatically. The user owns build and validation unless they explicitly ask Codex to run it.
