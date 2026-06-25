# Requirements Prompt

You are helping with SPDD for this task:

Task: `10.10 Add focused tests and manual validation for relaunch restore UX, actionable validation focus, camera evidence metadata, stopwatch timing, keyboard dismissal, VoiceOver operation, and common judge recovery paths.`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible or reviewer-visible outcome
- Acceptance source, especially `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature` when relevant
- Required behavior
- Out of scope behavior
- Completion signal
- PR review risk if this task grows too broad

Keep this focused on what must be true, not how to build it.

Context:

- Macro-task: TASK#10 Local Stored Judge Experience UX Follow-up
- Subtask: TASK#10.10
- Expected PR title: `TASK#10.10: Focused Tests Manual Validation`
- Feature branch: `codex/inspection-event-local-judge-ux`
- Suggested task branch: `codex/inspection-event-local-judge-ux-10-10-focused-tests-manual-validation`
- Operation summary: Add focused Swift Testing checks and manual validation for restore, blocker focus, evidence metadata, stopwatch, keyboard, VoiceOver, and recovery paths.
- Likely files or targets: Tests; validation checklist; PR notes
- Validation: Swift Testing plus manual validation evidence.
- Split trigger: Keep as validation PR if implementation work is already large.
- Common instructions:
- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
