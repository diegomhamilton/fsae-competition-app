# Requirements Prompt

You are helping with SPDD for this task:

Task: `10.9 Add stopwatch-style timing support for egress-test measurement steps, including start, stop, reset, manual override, validation against the allowed range, draft persistence, and accessible announcements.`

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
- Subtask: TASK#10.9
- Expected PR title: `TASK#10.9: Egress Stopwatch`
- Feature branch: `codex/inspection-event-local-judge-ux`
- Suggested task branch: `codex/inspection-event-local-judge-ux-10-9-egress-stopwatch`
- Operation summary: Add egress stopwatch timing with manual override, range validation, draft persistence, and accessibility announcements.
- Likely files or targets: Timing model/service/UI; tests
- Validation: Swift Testing timer/range/persistence checks and accessibility manual note.
- Split trigger: Split if timer engine and UI integration both grow.
- Common instructions:
- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
