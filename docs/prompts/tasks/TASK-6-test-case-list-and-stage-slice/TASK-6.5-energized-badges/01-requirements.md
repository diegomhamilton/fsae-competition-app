# Requirements Prompt

You are helping with SPDD for this task:

Task: `6.5 Add energized dynamic test badge derivation for EV inspection steps and expose equivalent accessibility information.`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible outcome for a judge reviewing energized EV dynamic test steps
- Acceptance source, especially `inspection-event-json-content` and accessibility requirements
- Required behavior
- Out of scope behavior
- Completion signal

Keep this focused on what must be true, not how to build it.

Context:

- Branch: `codex/task-6.5-energized-badges`
- Expected PR title: `TASK#6.5: Add energized badges`
- This task depends on JSON-backed EV inspection content being decodable and visible in stage/list views.
- Energized dynamic test steps must show a visible `CAUTION: ENERGIZED` badge and equivalent VoiceOver/accessibility information.
- The safety state must not rely on color alone.
- Do not perform the full stable accessibility identifier or structured string sweep from TASK#6.6 in this task.
- Do not build automatically. The user owns build and validation unless explicitly requested.
