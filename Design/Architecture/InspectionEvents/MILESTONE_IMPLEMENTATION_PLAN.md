# Milestone Implementation Plan — Inspection App

This plan sequences implementation after the Phase 4 MVVM blueprint and current UI proposal.

Sources:
- `Design/Architecture/InspectionEvents/PHASE4_MVVM_BLUEPRINT.md`
- `Design/UI/DESIGN_PROPOSAL.md`

---

## Milestone 1: Team + Stage Flow

Goal: make the core inspection execution loop solid before adding multi-team complexity.

Scope:
- Support one active team only.
- Make `Team` and `Stage` the primary tabs.
- Include Step detail as a drill-in destination from Stage.
- Keep draft edits in memory only.
- Exclude session selector, team switching, durable persistence, history, and re-submission.

Implementation work:
- Load bundled inspection JSON from `Design/Resources/InspectionEvent`.
- Map bundled JSON into domain models for stages, test cases, test steps, rules, and initial step results.
- Add an in-memory draft store keyed by `stepId`.
- Implement validation for required verdicts, notes-on-fail, measurement values, and required evidence metadata.
- Implement `ActiveTeamDashboardViewModel` for one active team with stage progress and blocker counts.
- Implement `StageExecutionViewModel` as the owner of inline verdict, notes, measurement, evidence status/actions, progress, blockers, submit gating, and Step drill-in intent.
- Implement `StepDetailViewModel` as a focused editor over the same in-memory draft `StepResult` state used by Stage.

Acceptance criteria:
- Team tab opens with the one active team.
- Team tab shows current stage, overall progress, open blockers, and stage rows.
- Selecting a stage opens Stage.
- Stage supports inline verdict, notes, measurement, and evidence metadata edits.
- Step detail opens from a Stage row and reflects edits back into Stage.
- Stage submit is blocked until validation passes.
- Edits persist while the app process is alive and reset on relaunch.

---

## Milestone 2: Multi-Team + Context Switching

Goal: add event workflow support after the single-team inspection flow is stable.

Scope:
- Add session selector.
- Add multiple team support.
- Add local draft persistence.
- Add save-before-switch confirmation.
- Restore active team/stage/step context after switching or relaunch.

Implementation work:
- Implement `SessionSelectorViewModel` for team/session listing and create-or-resume behavior.
- Replace the Milestone 1 hardcoded active team with selected/resumed `InspectionSession` state.
- Add `SessionPersistenceService` for draft save, session restore, and session index loading.
- Implement `TeamSwitchViewModel` for dirty draft detection, save-before-switch, target team loading, and switch errors.
- Scope validation, progress, and draft state by `eventId + teamId + sessionId`.

Acceptance criteria:
- Judges can select or resume a team session.
- Switching teams requires confirmation when draft changes exist.
- Drafts survive app relaunch.
- Returning to a team restores the current stage and nearest valid step context.

---

## Milestone 3: Re-Submission Flow

Deferred. This milestone will add re-submission support after Milestone 2 is complete and stable.
