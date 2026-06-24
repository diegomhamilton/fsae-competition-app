# Requirements Prompt

You are helping with SPDD for this task:

Task: `10.3 Refine the test case screen so the primary next judge action is visually dominant: compact case summary, actionable validation message, and focused step editor for one-step cases.`

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
- Subtask: TASK#10.3
- Expected PR title: `TASK#10.3: Test Case Next Action`
- Feature branch: `codex/inspection-event-local-judge-ux`
- Suggested task branch: `codex/inspection-event-local-judge-ux-10-3-test-case-next-action`
- Operation summary: Refine test case screen around the judge's next action, compact summary, validation message, and focused one-step editor.
- Likely files or targets: TestCaseView; view state; tests
- Validation: Swift Testing and manual checks for one-step and multi-step cases.
- Split trigger: Split if editor refactor touches step models or persistence.
- Common instructions:
- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
