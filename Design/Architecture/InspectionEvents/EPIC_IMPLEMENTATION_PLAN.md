# Epic Implementation Plan — Inspection App

This plan sequences high-level Epics after the Phase 4 MVVM blueprint and current UI proposal. Each Epic may contain multiple Milestones, and each Milestone may contain multiple PR-sized task branches.

Sources:
- `Design/Architecture/InspectionEvents/PHASE4_MVVM_BLUEPRINT.md`
- `Design/UI/DESIGN_PROPOSAL.md`
- `Design/Architecture/InspectionEvents/EPIC1_TASK_PLAN.md`

---

## Roadmap Format

Epics:
- Represent major product capabilities.
- Merge to `develop` only after all Epic Milestones and task PRs are complete.
- May receive their own detailed task plan document before implementation begins.

Milestones:
- Represent reviewable phases inside an Epic.
- Group task PRs around one main architectural or user-facing goal.

Task PRs:
- Are the smallest planned review unit.
- Should prove one behavior or architectural slice.
- Should include incremental unit tests where domain, validation, state, or persistence behavior changes.

---

## Epic Roadmap

| Epic | Name | Goal | Detailed Plan |
|---|---|---|---|
| 1 | One-Team Inspection Stages Workflow | Implement the core inspection execution loop for one active team/session using the existing SwiftUI skeleton, domain-backed state, validation, and navigation. | `EPIC1_TASK_PLAN.md` |
| 2 | One-Team Context Persistence | Persist one active team's draft results and current context locally, then restore that context across relaunch. | To be created |
| 3 | Multi-Team Sessions + Context Switching | Add event workflow support for selecting/resuming multiple team sessions and switching teams safely. | To be created |
| 4 | Re-Submission Flow | Add re-submission support after multi-team sessions and durable drafts are stable. | To be created |

Additional Epics will be added as the feature progresses.

---

## Epic 1 — One-Team Inspection Stages Workflow

Goal:
- Implement the inspection execution workflow for one active session/team by replacing mock state in the existing SwiftUI skeleton with domain-backed state, view models, validation, and navigation.

Scope:
- One active team/session only.
- Team and Stage are the primary tabs for the active workflow.
- Step detail is a drill-in destination from Stage.
- Draft edits live only for the current app process.
- Stage submission is blocked until validation passes.
- Existing SwiftUI skeleton views, navigation shape, and design components are the starting point.

Milestones:
| Milestone | Name | Goal |
|---|---|---|
| 1 | Inspection Content Foundation | Load bundled inspection content into stable domain models without editable draft state. |
| 2 | Single Active Team Shell | Route the existing SwiftUI skeleton into one active team/session workflow. |
| 3 | Runtime Draft Editing Foundation | Introduce process-lifetime draft state shared by Stage and Step detail. |
| 4 | Validation Pipeline | Add submit-blocking validation rules incrementally. |
| 5 | Stage Execution UI | Replace mock Stage behavior with editable, validation-aware execution. |
| 6 | Step Detail and Navigation | Add drill-in editing and complete expected back flows. |
| 7 | Epic Integration and Cleanup | Remove active mock dependencies and validate the complete one-team loop. |

Non-goals:
- Multi-team selection and team switching.
- Durable draft persistence across relaunches.
- Historical submissions.
- Re-submission flow.
- Attachment file storage, camera/file picker integration, and preview rendering.
- A from-scratch rewrite of the app UI.

Clarifications:
- "No durable persistence" means Epic 1 does not write draft inspection state to storage that survives app relaunch.
- "Draft edits live only for the current app process" means editable results may be shared through runtime state while the app is open, but reset when the app starts again.
- Evidence support in Epic 1 is metadata-only: enough to validate whether required evidence is marked present. Actual attachment file storage is deferred.
- Dashboard progress and blocker counts become real only after draft state and validation exist. Before then, dashboard summaries should be explicit baseline values such as `0%`, `Not started`, or `Not evaluated`.

Completion criteria:
- Team tab opens with one active team.
- Team tab shows current stage, overall progress, open blockers, and stage rows.
- Selecting a stage opens Stage.
- Stage supports inline verdict, notes, measurement, and evidence metadata edits.
- Step detail opens from a Stage row and reflects edits back into Stage.
- Back navigation works for Stage-to-Team and Step-to-Stage flows.
- Stage submit is blocked until validation passes.
- Edits persist while the app process is alive and reset on relaunch.

Detailed plan:
- `Design/Architecture/InspectionEvents/EPIC1_TASK_PLAN.md`

---

## Epic 2 — One-Team Context Persistence

Goal:
- Persist the one active team's draft results and active inspection context after the one-team execution flow is stable, allowing the same team/session to resume after app relaunch before multi-team selection is introduced.

Scope:
- Local durable draft persistence.
- Local persistence for the single active team's session metadata.
- Active stage/step context restore after relaunch.
- Durable storage contract for draft results, evidence metadata, and navigation context.
- Migration/version fields needed for local draft compatibility.
- Validation and progress restored from persisted one-team draft state.

Non-goals:
- Multi-team selection.
- Team switching.
- Save-before-switch confirmation.
- Historical submission timeline.
- Re-submission flow.
- Cloud sync.
- Cross-device collaboration.
- Full attachment media lifecycle unless explicitly included in the detailed Epic 2 architecture plan.

High-level Milestones:
| Milestone | Name | Goal |
|---|---|---|
| 1 | Persistence Contract | Define the local storage shape for one active session, draft results, evidence metadata, and current context. |
| 2 | Draft Save and Load | Persist and reload one team's draft results without adding team selection. |
| 3 | Context Restore | Restore current stage, selected step, and active tab after relaunch. |
| 4 | Restored Validation and Progress | Rebuild validation summaries and progress from persisted one-team draft state. |
| 5 | Persistence Integration and Acceptance | Validate one-team edit/relaunch/resume flows end to end. |

Expected implementation work:
- Add `SessionPersistenceService` for one active session draft save/load.
- Persist `StepResult` draft values, evidence metadata, and active context.
- Restore the one active team/session context when the app launches.
- Rehydrate Team, Stage, and Step view models from persisted state.
- Add migration/version fields needed for future persistence compatibility.

Acceptance criteria:
- Draft edits for the one active team survive app relaunch.
- Relaunch restores the active team, current stage, and nearest valid step context.
- Validation summaries and progress are rebuilt from restored draft state.
- Persistence remains scoped to one active session and does not expose multi-team selection.

Detailed plan:
- To be created in a dedicated Epic 2 planning chat/worktree before implementation.

---

## Epic 3 — Multi-Team Sessions + Context Switching

Goal:
- Add event workflow support after one-team persistence is stable, allowing judges to select/resume multiple team sessions and switch teams safely without losing draft work.

Scope:
- Session selector for team/session listing.
- Multiple team support.
- Create-or-resume behavior per team/session.
- Save-before-switch confirmation when draft changes exist.
- Active team/stage/step context restore after switching teams.
- Validation, progress, and draft state scoped by `eventId + teamId + sessionId`.

Non-goals:
- Historical submission timeline.
- Re-submission flow.
- Cloud sync.
- Cross-device collaboration.
- Full attachment media lifecycle unless explicitly included in the detailed Epic 3 architecture plan.

High-level Milestones:
| Milestone | Name | Goal |
|---|---|---|
| 1 | Session Selection Foundation | Reactivate and domain-bind the session selector for team/session listing and create-or-resume behavior. |
| 2 | Multi-Team Session Index | Extend persistence from one active session to a session index across teams. |
| 3 | Team Switching Safety | Add dirty-draft detection and save-before-switch confirmation before changing active teams. |
| 4 | Scoped Validation and Progress | Scope draft state, validation, and progress by `eventId + teamId + sessionId`. |
| 5 | Multi-Team Integration and Acceptance | Validate create/resume/switch/relaunch flows across multiple teams end to end. |

Expected implementation work:
- Implement `SessionSelectorViewModel` for team/session listing and create-or-resume behavior.
- Replace the Epic 2 one-active-session startup with selected/resumed `InspectionSession` state.
- Extend `SessionPersistenceService` for session index loading and multiple team/session records.
- Implement `TeamSwitchViewModel` for dirty draft detection, save-before-switch, target team loading, and switch errors.
- Update Team, Stage, and Step view models to use fully session-scoped state.

Acceptance criteria:
- Judges can select or resume a team session.
- Switching teams requires confirmation when unsaved draft changes exist.
- Drafts survive app relaunch for multiple teams.
- Returning to a team restores current stage and nearest valid step context.
- Team, stage, and step progress do not leak across teams or sessions.

Detailed plan:
- To be created in a dedicated Epic 3 planning chat/worktree before implementation.

---

## Epic 4 — Re-Submission Flow

Goal:
- Add re-submission support after Epic 3 is complete and stable.

Deferred scope:
- Submission history.
- Immutable submission snapshots.
- Re-submission entry points.
- Comparison between previous submitted state and current draft.
- Rules for preserving historical traceability.

Detailed plan:
- To be created after Epic 3 architecture is stable.
