---
title: Judge Navigation Flow Proposal
domain: inspection-event
status: proposed
owners: [documenter-agent]
doc_hooks:
  upstream:
    - Design/Flows/InspectionEvents/PHASE2_FLOW_SET.md
    - Design/Flows/InspectionEvents/PHASE3_SCREEN_MAP.md
    - Design/UI/DESIGN_PROPOSAL.md
    - Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature
    - docs/system-map.md
    - docs/prompts/tasks/TASK-10-local-stored-judge-experience-ux-follow-up/TASK-10.1-ux-audit/01-requirements.md
    - docs/prompts/tasks/TASK-10-local-stored-judge-experience-ux-follow-up/TASK-10.1-ux-audit/05-operations.md
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/App/ContentTabsView.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/App/EmptyFlowState.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/App/ProposedScreen.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Coordinators/AppCoordinator.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Coordinators/InspectionEventCoordinator.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Coordinators/SessionSelectionCoordinator.swift
    - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/SessionFlow/Coordinators/InspectionExecutionCoordinator.swift
  downstream:
    - docs/prompts/tasks/TASK-10-local-stored-judge-experience-ux-follow-up/TASK-10.3-guided-navigation/README.md
    - docs/prompts/tasks/TASK-10-local-stored-judge-experience-ux-follow-up/TASK-10.5-actionable-validation-blockers/README.md
    - docs/prompts/tasks/TASK-10-local-stored-judge-experience-ux-follow-up/TASK-10.10-focused-tests-manual-validation/README.md
---

# Judge Navigation Flow Proposal

This proposal defines the intended navigation model for the local stored judge
workflow before broad UI changes are implemented. It answers TASK#10.1
recommended implementation order item 4: decide the tab model, guided routing,
empty-state strategy, and blocked-correction behavior for sessions, team
dashboard, stage, test case, and step detail.

This is a documentation and design artifact only. It does not change SwiftUI
views, coordinator state, persistence, submission, recheck, or sticker behavior.

## Decision Summary

Adopt a guided judge route with three durable top-level destinations and
context-bound drill-ins:

- `Sessions`: choose, resume, or correct a team session.
- `Team`: review active team context, stage status, blockers, and team switching.
- `Stage`: execute the current stage and submit when validation passes.
- `Test Case`: routed drill-in from Stage or a blocker, not a primary judge tab.
- `Step Detail`: routed drill-in from Test Case, Stage, or a blocker, not a
  primary judge tab.

The current five-tab implementation can remain as a temporary shell while the
flow is stabilized. The intended model should treat `Case` and `Step` as
contextual destinations that are only useful after the app has an active session,
stage, and selected item. If a later UI slice keeps them visible as tabs, they
must behave as guided shortcuts back to the relevant context rather than inert
blank destinations.

## Current-State Constraints

`ContentTabsView` currently exposes `Sessions`, `Team`, `Stage`, `Case`, and
`Step` as sibling tabs bound to `ProposedScreen`. Each tab owns a
`NavigationStack`, but route changes mostly happen through coordinator-driven tab
selection rather than push navigation. Missing context renders `EmptyFlowState`
with a short text message.

This shape is useful for prototype review because each surface is easy to open,
but it creates judge-facing ambiguity:

- Judges can tap `Team`, `Stage`, `Case`, or `Step` before selecting a team.
- A missing active stage, test case, or step appears as a static message instead
  of routing the judge to the next useful action.
- Blocked team rows are visible in the session selector, but current routing
  treats blocked selection as a failed start/resume attempt.
- Validation blockers deep-link toward test steps, but the broader route contract
  for blocked correction is not documented yet.

## Proposed Route Contract

### Launch and Session Selection

Entry: app launch, relaunch restore failure, explicit team switch, or cancelled
active context.

Expected route:

1. Show `Sessions`.
2. Load event roster and stored session state.
3. Sort or group teams so active/resumable/blocked sessions remain easy to find.
4. Selecting a `not_started` team creates a local session and routes to `Team`.
5. Selecting an `in_progress` team restores its saved context and routes to
   `Team`.
6. Selecting a `blocked` team opens correction mode instead of failing selection.

The session selector should never be a dead end for a visible team row. If a team
is unavailable because the roster or stored session record is corrupt, the row
should show an error/retry state and keep the judge on `Sessions`.

### Active Team Dashboard

Entry: successful team start/resume, successful team switch, stage submission, or
return from stage work.

Expected route:

1. Show stable event, team, session, last-saved, and current-stage context.
2. Make the primary action continue the next actionable stage.
3. Surface blockers as action rows grouped by stage or test case.
4. Route stage rows to `Stage`.
5. Route blocker rows to the most specific available correction target:
   `Step Detail` when a step is known, `Test Case` when only the case is known,
   or `Stage` when only the stage is known.
6. Keep team switching anchored here because it changes active team context.

The dashboard is the judge's home base for active work. It should answer:
"Which team am I inspecting, what stage needs attention, and what should I do
next?"

### Stage

Entry: dashboard stage row, continue-stage action, restored active stage, or
blocked-correction fallback when only a stage is known.

Expected route:

1. Show stage context and the ordered sections/test cases.
2. Support common inspection work inline: outcome, notes, measurements, evidence
   metadata, validation summary, and submit.
3. Route explicit test-case controls to `Test Case`.
4. Route validation summary blockers to the first invalid `Step Detail` when
   possible.
5. After successful submission, return to `Team` with updated stage status and a
   next-stage or review-completion action.
6. If submission is blocked, remain on `Stage` and route correction actions to
   the exact missing outcome, note, measurement, or evidence field when known.

`Stage` remains the primary work surface. Judges should not need to visit
`Test Case` or `Step Detail` for routine pass/fail entry unless a step has long
text, measurement correction, evidence metadata, or a validation blocker.

### Test Case

Entry: stage test-case row, dashboard blocker row, stage validation summary, or
relaunch restore where a selected test case is known.

Expected route:

1. Show the active team, stage, test case title, progress, and blocker count.
2. Preserve the active stage context so returning lands the judge in the same
   stage.
3. Provide a first-incomplete or first-blocked step action.
4. Route step rows to `Step Detail`.
5. Allow correction completion to return to `Stage` or remain in `Test Case`
   depending on the source route.

`Test Case` should be a detail surface for a bounded chunk of work, not an
independent tab where a judge has to rediscover which stage or team they were in.

### Step Detail

Entry: test-case step row, stage step-detail affordance, validation blocker, or
restore context when a selected step is known.

Expected route:

1. Show team, stage, test case, step ID/title, and requirement metadata.
2. Focus the relevant correction field when the route came from a blocker.
3. Persist corrections immediately through the existing draft-save path.
4. Provide clear return destinations: back to `Test Case` for local case work,
   or back to `Stage` for blocker correction from the validation summary.
5. If the selected step is no longer valid after content/session repair, route to
   the nearest valid `Test Case` or `Stage` with a non-blocking repair notice.

`Step Detail` should feel like a focused editor, not a separate mode of the app.
It is opened because the judge needs room, context, or help correcting a precise
issue.

### Team Switch Confirmation

Entry: dashboard team-switch action when switching may affect active draft
context.

Expected route:

1. Keep the sheet modal because switching teams is a context-changing action.
2. Show current team, target team, save state, and failure/retry status.
3. Confirming saves the current draft context before loading the target team.
4. On success, route to `Team` for the target team.
5. On failure, keep the current team active and keep the judge on the
   confirmation/error state with retry and cancel.

Target team selection can be a later flow. This proposal only requires that
confirmation not silently mutate context or strand the judge away from the active
team.

## Blocked Correction Model

A blocked state means "inspection work is resumable and needs correction," not
"this session cannot open."

Blocked correction should use the same route contract as normal inspection, with
an additional correction intent:

1. `Sessions` row shows the team as blocked with the stage/test-case reason when
   known.
2. Selecting the row restores the team's session and enters correction mode.
3. If a persisted blocker target is known, route directly to the deepest useful
   screen:
   - step target known: `Step Detail`
   - test case known: `Test Case`
   - stage known: `Stage`
   - only team known: `Team`
4. The destination shows a visible correction context and a way back to the
   active team dashboard.
5. Corrections autosave and re-run validation.
6. Once blockers are clear, the judge returns to `Stage` to submit or to `Team`
   if the stage was already submitted and only recheck/sticker state changed.

This model keeps blocked teams operationally visible without making blocked rows
feel like broken controls.

## Empty-State Strategy

Replace text-only placeholders with context-aware empty states. Every empty state
must include:

- Reason: why the requested destination has no content.
- Current context: event/team/stage/test case when available.
- Primary action: the next valid route.
- Secondary action when useful: return to dashboard, select team, retry load, or
  cancel.
- Stable accessibility identifier for the empty state and its primary action.

Recommended empty states:

| Surface | Empty or invalid condition | Primary action | Secondary action |
| --- | --- | --- | --- |
| `Sessions` | roster unavailable | retry loading roster | continue with last restored team only if valid |
| `Sessions` | no teams for event | refresh or choose event | none until event selection exists |
| `Team` | no active session | select team | retry restore if a stored session exists |
| `Stage` | no active team | select team | none |
| `Stage` | no active stage | open current stage from dashboard | select another stage if available |
| `Stage` | stage has no actionable steps | return to dashboard | retry content load |
| `Test Case` | no selected test case | open first incomplete test case | return to stage |
| `Test Case` | selected test case no longer exists | open nearest valid test case | return to stage |
| `Step Detail` | no selected step | open first incomplete step | return to test case |
| `Step Detail` | selected step no longer exists | open nearest valid step | return to test case |
| `Team Switch` | no target team selected | choose target team | cancel switch |

Empty states should be route repair points. They should not be used as the normal
way a judge discovers the workflow.

## Tab Model Recommendation

Recommended product model:

- Keep `Sessions`, `Team`, and `Stage` as top-level judge landmarks.
- Demote `Case` and `Step` from persistent tabs to routed drill-ins, because they
  require active parent context and are not useful as independent destinations.
- During the transition, the current five-tab shell may remain if `Case` and
  `Step` tabs are guarded by action-oriented empty states and preserve valid
  route context.
- Do not add more top-level tabs for rechecks, sticker eligibility, or history
  until their primary judge entry point is proven. Prefer dashboard sections and
  routed details first.

Rationale:

- The feature scenarios describe a linear operational flow: select/resume team,
  inspect stage, correct blockers, submit, switch teams, and review history.
- `Stage` is the only surface that can complete the common inspection loop end to
  end.
- Top-level `Case` and `Step` tabs expose invalid states too easily and make
  recovery depend on the judge understanding app internals.
- Guided drill-ins align with validation correction because blocker actions can
  carry precise route payloads.

## Follow-Up Implementation Boundaries

Keep implementation slices small:

- TASK#10.3 guided navigation: remove the standalone `Case` tab, keep
  `Sessions`, `Team`, and `Stage` as top-level landmarks, and compose case-level
  execution UI inside Stage with step detail remaining a guided drill-in.
- Blocked re-inspection route: change blocked row selection from failed intent to
  correction intent, with tests for route selection.
- Empty-state route actions: add context-aware actions and identifiers without
  redesigning every screen.
- Validation focus routing: route blocker selection to exact test case/step/field
  targets, then persist corrections immediately.
- Submission and history: wire `Submit Stage` and immutable snapshot behavior in
  a separate slice.

Do not combine tab restructuring, blocked correction, submission, rechecks,
sticker eligibility, and team-switch recovery in one PR.

## Validation Readback

Readback performed for this proposal:

- TASK#10.1 requirements and operations prompts.
- TASK#10 local stored judge UX common direction via the task README and
  operations summary.
- Phase 2 flow set and Phase 3 screen map.
- Gherkin scenarios for session start/resume, blocked submission correction,
  measurement/evidence validation, team switching, and history empty states.
- Current system map and UI proposal.
- Current routing and empty-state source files listed in `doc_hooks.upstream`.

No build or Swift Testing run is required for this documentation-only proposal.
