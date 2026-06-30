## 1. Prepare Foundation Slice

- [ ] 1.1 Confirm `design-review-local-judge-ux-enhancements` is complete and this slice scope is approved.
- [ ] 1.2 Audit `SessionSelectorView`, `ActiveTeamDashboardView`, `FullStageView`, `TestCaseView`, `StepOverviewView`, and `TeamSwitchConfirmationView` for prototype copy, unclear navigation, and dead-end states.
- [ ] 1.3 Add failing tests or view-state assertions for the approved UX foundation behavior.

## 2. Context and Copy Cleanup

- [ ] 2.1 Replace prototype header/background treatment and mock-state copy with stable event, team, session, stage, and test case context.
- [ ] 2.2 Ensure restored local session state makes the active team, stage, draft status, and next action obvious.
- [ ] 2.3 Refine the test case screen so the primary next judge action is visually dominant.
- [ ] 2.4 Refactor step metadata layout so step ID/title/status come first and rule references move to a secondary row.

## 3. Validation and Draft Recovery

- [ ] 3.1 Make validation blockers selectable so they focus or route to the missing outcome, note, measurement, or evidence control.
- [ ] 3.2 Persist corrections immediately to the test case JSON draft.
- [ ] 3.3 Review pending semantics and present incomplete required steps as derived state rather than judge-selected outcome.
- [ ] 3.4 Clarify notes and evidence labels for empty, required missing, present, add, edit, and count states.

## 4. Validation

- [ ] 4.1 Run focused view-state, validation, coordinator, and persistence tests touched by this slice.
- [ ] 4.2 Manually validate relaunch restore UX, actionable validation focus, keyboard dismissal, VoiceOver operation, and common judge recovery paths.
- [ ] 4.3 Update PR notes with feature scenario mapping and design-review decisions.

