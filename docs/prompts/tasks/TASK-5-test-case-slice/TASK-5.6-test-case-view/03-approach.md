# Approach Prompt

Given this task and entities:

Task: `5.6 Refactor the existing stage step card pattern into a test case view that renders ordered steps and validation summaries.`

Entities: `<paste entity summary>`

Propose a high-level implementation approach.

Include:

- Files or areas likely affected
- Test-first strategy for view helpers, models, or validation-summary shaping
- Existing patterns to follow from `FullStageView` and `StageChecklistView`
- How to refactor the stage step card pattern without broad stage-flow rewrites
- How ordered steps should be derived from mock JSON/model state
- How validation summaries should be rendered
- SwiftUI / Swift 6 / Concurrency considerations
- Accessibility and localization considerations
- Manual validation path

Do not write code yet. Explain the solution shape and collaboration points.

Required context to read before implementation:

- OpenSpec proposal, design, tasks, and specs
- Relevant `.feature` file
- `agents/SwiftAgents/AGENTS.md`
- Current stage and step views
- `KeyboardDismissBar.swift`
- Relevant models and services from tasks 5.3 and 5.4, if present

Constraints:

- Work on branch `codex/task-5.6-test-case-view`.
- Expected PR title is `TASK#5.6: Add test case view`.
- Include structured `Strings` enum values for new visible text.
- Include stable accessibility identifiers for actionable controls and statuses introduced here.
- Keep one keyboard dismissal affordance for repeated note inputs, respecting TASK#5.0 behavior.
- Do not implement bundled stage loading.
- Do not add UI tests.
- Do not build automatically; the user owns build and validation unless explicitly requested.
