# TASK#10.3 SPDD Prompt Run

Task: `10.3 Refactor judge navigation so Sessions, Team, and Stage are the top-level landmarks, remove the standalone Case tab, and make Stage contain the case UI with dominant next-action and focused one-step editing.`

Purpose: Implement the guided navigation refactor from `Design/Flows/InspectionEvents/JUDGE_NAVIGATION_FLOW_PROPOSAL.md` so Stage owns case-level execution UI and the judge no longer sees a separate Case tab.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: ContentTabsView; ProposedScreen; AppCoordinator/InspectionExecutionCoordinator route handling; FullStageView; TestCaseView; view state; tests
- Validation: Swift Testing for route transitions plus manual checks for one-step cases, multi-step cases, relaunch restore, empty states, and VoiceOver.
- Split trigger: Split if route model changes and Stage/Case UI composition cannot be reviewed together.

Expected PR title:

`TASK#10.3: Guided Navigation`

Branch:

`codex/inspection-event-local-judge-ux-10-3-guided-navigation`

Common instructions:

- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
