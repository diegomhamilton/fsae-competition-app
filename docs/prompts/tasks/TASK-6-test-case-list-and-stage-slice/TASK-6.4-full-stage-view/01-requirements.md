# Requirements Prompt

You are helping with SPDD for this task:

Task: `6.4 Refactor FullStageView to render real stage content, stage progress, validation blockers, and submit controls from model state.`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible outcome for a judge inspecting a stage
- Acceptance source, especially stage opening and validation-gated submission scenarios
- Required behavior
- Out of scope behavior
- Completion signal

Keep this focused on what must be true, not how to build it.

Context:

- Branch: `codex/task-6.4-full-stage-view`
- Expected PR title: `TASK#6.4: Refactor full stage view`
- This task depends on TASK#6.2 content loading and TASK#6.3 grouped test case list rendering.
- `FullStageView` must show real stage title/content, progress, validation blockers, and submit-ready or blocked controls from model/draft state.
- Do not implement session submission snapshots, rechecks, sticker eligibility, energized badge derivation, accessibility identifier sweep, or manual validation docs in this task.
- Do not build automatically. The user owns build and validation unless explicitly requested.
