# Requirements Prompt

You are helping with SPDD for this task:

Task: `10.4 Refactor step metadata layout to avoid wrapping/truncation in compact widths and larger Dynamic Type: show step ID/title/status first, move rule references to a secondary row, and keep the open-step action compact.`

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
- Subtask: TASK#10.4
- Expected PR title: `TASK#10.4: Step Metadata Layout`
- Feature branch: `codex/inspection-event-local-judge-ux`
- Suggested task branch: `codex/inspection-event-local-judge-ux-10-4-step-metadata-layout`
- Operation summary: Refactor step metadata layout for compact widths and larger Dynamic Type.
- Likely files or targets: StepOverviewView; metadata components; previews/tests
- Validation: Dynamic Type and compact width checks.
- Split trigger: Split if rule reference presentation becomes reusable component work.
- Common instructions:
- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
