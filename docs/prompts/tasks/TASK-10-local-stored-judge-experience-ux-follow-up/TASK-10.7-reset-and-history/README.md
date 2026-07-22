# TASK#10.7 SPDD Prompt Run

Task: `10.7 Add session recovery and history: reset an active session with confirmation, preserve past completed executions, show past sessions with start/end timestamps, and document the validation path for checking past executions.`

Purpose: give judges a safe recovery path while preserving completed local execution history.

Branch: `codex/task-10-7-reset-and-history`

Expected PR title: `TASK#10.7: Reset and Session History`

Run prompts in this order:

1. Requirements: read common instructions, `.feature` history and session scenarios, and current persistence/submission/session views.
2. Entities: identify reset intent, confirmation state, completed session summaries, timestamp formatting, history navigation, and immutable snapshot display boundaries.
3. Approach: add failing tests for reset confirmation, active draft cleanup, completed history preservation, empty history, and timestamp display state.
4. Structure: implement reset/history through coordinator and store/service APIs; keep historical records read-only in UI.
5. Operations: implement, validate, update OpenSpec checkbox, commit, push, and open a draft PR automatically.
6. Norms: use accessible confirmation controls and non-destructive reset semantics.
7. Safeguards: reset must not delete completed sessions; do not add recheck/sticker functionality.

Agent/skill/tool mapping: use `../common-instructions.md`.

Validation:

- Reset asks for confirmation and clears only active in-progress state.
- Completed executions remain visible with start/end timestamps.
- Empty history has a clear read-only state.
- Manual validation maps to `Historical submissions are visible but immutable`.
