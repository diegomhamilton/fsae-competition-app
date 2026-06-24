# Requirements Prompt

You are helping with SPDD for this task:

Task: `10.8 Add camera/photo capture support for evidence-required steps, persisting captured file metadata with the test case JSON draft while keeping full media storage behind a reviewed storage policy.`

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
- Subtask: TASK#10.8
- Expected PR title: `TASK#10.8: Camera Evidence Metadata`
- Feature branch: `codex/inspection-event-local-judge-ux`
- Suggested task branch: `codex/inspection-event-local-judge-ux-10-8-camera-evidence-metadata`
- Operation summary: Add metadata-first camera/photo capture support for evidence-required steps.
- Likely files or targets: Evidence metadata; capture adapter; UI affordance; tests
- Validation: Metadata persistence checks and manual capture smoke notes.
- Split trigger: Split if platform permissions or media storage policy enters scope.
- Common instructions:
- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
