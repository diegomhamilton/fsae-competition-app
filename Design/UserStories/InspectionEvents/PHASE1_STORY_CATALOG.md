# Phase 1 User Story Catalog — Inspection App

Source: `context/DESIGN_PLAN.md` (Phase 1).

## Scope
Define behavior contracts (stories) before flows/screens/architecture.

## Assumptions
- Inspection session scope is one team + one event context at a time.
- Step types in scope for this phase: `outcome`, `measurement`, `evidence`.
- “Submission history” is read-only in Phase 1.

## Personas
| Persona | Priority | Goal |
|---|---|---|
| Judge | Primary | Execute inspection stages quickly with validation integrity. |
| Team Reviewer | Secondary | Review submitted outcomes, notes, and evidence references. |
| Event Admin | Future | Configure event policy and audit consistency. |

## Story Catalog (US-001...US-007)

### US-001 — Start or Select Team Inspection Session
- **Actor:** Judge
- **Trigger:** App launch / session start for event.
- **Expected Outcome:** Judge selects a team and enters correct active session context.
- **Acceptance Criteria:**
  1. Team list for current event is visible.
  2. Selecting a team creates new session or resumes existing `in_progress` session.
  3. Active context header shows team, event, and current stage.
  4. Resumable sessions are clearly labeled before entry.
- **Data Requirements:** event ID, team roster, team session status, last activity timestamp.

### US-002 — Complete Stage with Required Outcomes and Notes
- **Actor:** Judge
- **Trigger:** Judge attempts stage completion.
- **Expected Outcome:** Submission allowed only when required outcomes/notes constraints pass.
- **Acceptance Criteria:**
  1. Required outcome steps cannot remain unset.
  2. Failed outcome enforces note requirement when policy says so.
  3. Stage submit action is blocked until all required validations pass.
  4. Validation errors identify exact failing step and rule.
- **Data Requirements:** stage + ordered steps, per-step rules, step result payload, validation summary.

### US-003 — Enter Measurement Values
- **Actor:** Judge
- **Trigger:** Judge opens `measurement` step.
- **Expected Outcome:** Valid values are recorded; invalid values are rejected with correction path.
- **Acceptance Criteria:**
  1. Measurement input includes unit/context.
  2. Numeric format and precision constraints are enforced.
  3. Out-of-range values are blocked/flagged per policy.
  4. Values remain editable until stage submit.
- **Data Requirements:** measurement schema, format/precision rules, min/max policy, persisted value + edit timestamp.

### US-004 — Attach and Validate Evidence
- **Actor:** Judge
- **Trigger:** Judge opens evidence-capable step.
- **Expected Outcome:** Judge can manage attachments; required-proof rules gate submission.
- **Acceptance Criteria:**
  1. Judge can add attachment metadata to step.
  2. Added attachment metadata is visible in-step.
  3. Judge can remove/replace attachments before submit.
  4. Submit is blocked when required evidence is missing.
- **Data Requirements:** evidence-required rule, attachment metadata schema, per-step attachment collection, evidence validation state.

### US-005 — Resume After Relaunch
- **Actor:** Judge
- **Trigger:** App relaunch with in-progress work.
- **Expected Outcome:** Judge restores prior context and draft data without loss.
- **Acceptance Criteria:**
  1. In-progress sessions are discoverable at launch.
  2. Resume action restores most recent session directly.
  3. Draft outcomes/notes/measurements/evidence metadata are restored.
  4. Partial stage progress remains intact.
- **Data Requirements:** persisted session drafts, context pointer (team/stage/step), draft step data, version marker for migration-safe restore.

### US-006 — Switch Teams Safely
- **Actor:** Judge
- **Trigger:** Judge switches active team mid-event.
- **Expected Outcome:** No cross-team state leakage; previous team context recoverable.
- **Acceptance Criteria:**
  1. Unsaved change warning appears before switch.
  2. Current draft persists before switching.
  3. New team view shows only selected team session data.
  4. Switching back restores prior team’s exact draft context.
- **Data Requirements:** per-team session index, dirty-state marker, per-team draft snapshots, context isolation rules.

### US-007 — Review Historical Submissions
- **Actor:** Team Reviewer (Judge as secondary viewer)
- **Trigger:** User opens team/test-case history.
- **Expected Outcome:** User can inspect immutable past submissions.
- **Acceptance Criteria:**
  1. History list shows submission timestamp + status.
  2. Selected entry shows stage/step outcomes and notes.
  3. Historical evidence references are visible.
  4. Historical records are strictly read-only.
- **Data Requirements:** history index, immutable snapshots, submitter/timestamp metadata, read-only retrieval contract.

## Coverage Matrix (Phase 1 Must-Cover)
| Must-Cover Group | Story ID |
|---|---|
| Start/select team inspection session | US-001 |
| Complete stage with required outcomes/notes | US-002 |
| Enter measurement values | US-003 |
| Attach and validate evidence | US-004 |
| Resume after relaunch | US-005 |
| Switch teams safely | US-006 |
| Review historical submissions | US-007 |

## Gate A Check (Stories -> Flows)
- All high-priority capability groups map to at least one approved story ID.
- Story artifacts include actor/trigger/outcome/acceptance/data contract fields required for Phase 2 flow derivation.
