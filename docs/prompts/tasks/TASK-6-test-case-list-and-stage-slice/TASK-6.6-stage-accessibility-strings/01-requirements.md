# Requirements Prompt

You are helping with SPDD for this task:

Task: `6.6 Add structured Strings enums and stable accessibility identifiers to the stage and test case list files.`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible outcome for judges, including VoiceOver users
- Acceptance source, especially `inspection-event-accessibility-localization`
- Required behavior
- Out of scope behavior
- Completion signal

Keep this focused on what must be true, not how to build it.

Context:

- Branch: `codex/task-6.6-stage-accessibility-strings`
- Expected PR title: `TASK#6.6: Add stage accessibility IDs`
- This task depends on TASK#6.3 through TASK#6.5 stage/list UI behavior.
- Stage and test case list files must use structured `Strings` enums for visible and accessibility text.
- User-actionable controls, rows, status indicators, validation summaries, safety badges, and submit controls must expose stable accessibility identifiers separate from localized labels.
- Do not add broad dedicated UI automation or manual validation docs in this task.
- Do not build automatically. The user owns build and validation unless explicitly requested.
