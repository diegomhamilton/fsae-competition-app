# Requirements Prompt

You are helping with SPDD for this task:

Task: `10.5 Make validation blockers actionable by tapping or selecting a blocker to focus the missing outcome, note, measurement, or evidence control, then persist the correction immediately to the test case JSON draft.`

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
- Subtask: TASK#10.5
- Expected PR title: `TASK#10.5: Actionable Validation Blockers`
- Feature branch: `codex/inspection-event-local-judge-ux`
- Suggested task branch: `codex/inspection-event-local-judge-ux-10-5-actionable-validation-blockers`
- Operation summary: Make validation blockers selectable, focus missing controls, and persist corrections immediately.
- Likely files or targets: Validation UI; coordinator intents; persistence calls; tests
- Validation: Swift Testing focus routing and JSON draft persistence checks.
- Split trigger: Split if focus routing and persistence updates exceed one review context.
- Common instructions:
- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
