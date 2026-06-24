# Requirements Prompt

You are helping with SPDD for this task:

Task: `10.1 Audit SessionSelectorView, ActiveTeamDashboardView, FullStageView, TestCaseView, StepOverviewView, and TeamSwitchConfirmationView for the minimum UX polish needed after Task 7 so a judge can complete a fully local, stored inspection without prototype copy, unclear navigation, or dead-end states.`

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
- Subtask: TASK#10.1
- Expected PR title: `TASK#10.1: UX Audit`
- Feature branch: `codex/inspection-event-local-judge-ux`
- Suggested task branch: `codex/inspection-event-local-judge-ux-10-1-ux-audit`
- Operation summary: Audit stored local judge workflow screens for minimum UX polish after TASK#7.
- Likely files or targets: Audit doc; view notes; issue checklist
- Validation: Manual audit mapped to judge flow.
- Split trigger: Keep audit separate if it finds broad UI changes.
- Common instructions:
- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
