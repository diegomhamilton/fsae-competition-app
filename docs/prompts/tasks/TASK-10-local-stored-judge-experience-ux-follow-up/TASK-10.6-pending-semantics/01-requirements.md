# Requirements Prompt

You are helping with SPDD for this task:

Task: `10.6 Review Pending semantics so incomplete required steps are represented as derived draft state rather than a confusing judge decision when Pass, Fail, and N/A are the actual choices.`

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
- Subtask: TASK#10.6
- Expected PR title: `TASK#10.6: Pending Semantics`
- Feature branch: `codex/inspection-event-local-judge-ux`
- Suggested task branch: `codex/inspection-event-local-judge-ux-10-6-pending-semantics`
- Operation summary: Clarify Pending as derived incomplete state rather than a judge-selected outcome.
- Likely files or targets: Models; validation; UI labels; tests
- Validation: Swift Testing proves Pass/Fail/N/A are decisions and incomplete is derived.
- Split trigger: Split if migration from stored pending values is needed.
- Common instructions:
- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
