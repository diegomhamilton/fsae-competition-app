# Phase 2 Flow Set — Inspection App

Source stories: `Design/UserStories/InspectionEvents/PHASE1_STORY_CATALOG.md`.

## Flow Index
| Flow ID | Name | Story Mapping |
|---|---|---|
| FL-001 | Session Start / Resume | US-001, US-005 |
| FL-002 | Stage Execution + Submit Gating | US-002 |
| FL-003 | Measurement Entry + Correction | US-003 |
| FL-004 | Evidence Attach/Remove + Required-Proof Blocking | US-004 |
| FL-005 | Team Switch + Context Restore | US-006 |
| FL-006 | Historical Submission Inspection | US-007 |

---

## FL-001 — Session Start / Resume
**Story Mapping:** US-001, US-005

### Preconditions
- Event context is selected/available.
- Team roster is available.
- App can read persisted session index.

### Happy Path
1. Judge opens app and lands on session selector.
2. App loads teams and session states (`not_started`, `in_progress`, `submitted`).
3. Judge selects team.
4. If `not_started`, app creates session and enters first actionable stage.
5. If `in_progress`, app restores saved team/stage/step context.
6. Active header confirms team + event + stage.

### Validation Failures
- Session index unavailable/corrupt.
- Team roster missing/empty.
- Resume pointer references missing stage/step.

### Recovery Path
- Fallback to team selector with non-blocking error banner.
- Offer “start fresh session” only after explicit confirmation.
- If resume pointer invalid, restore nearest valid stage start and log repair event.

### Completion Condition
- Judge is in active team session with valid context loaded and editable.

---

## FL-002 — Stage Execution + Submit Gating
**Story Mapping:** US-002

### Preconditions
- Active team session exists.
- Current stage and steps are loaded with validation rules.

### Happy Path
1. Judge opens stage checklist.
2. Judge records outcomes step-by-step.
3. Judge enters notes for fail outcomes where required.
4. App evaluates rule compliance in real time.
5. Judge taps submit stage.
6. App runs final validation pipeline.
7. On pass, stage is submitted and locked as completed snapshot.

### Validation Failures
- Required outcome missing.
- Required note missing for failed step.
- Step-specific rule violation.

### Recovery Path
- Show inline step-level errors + summary banner.
- Jump-to-first-invalid-step action.
- Re-run validation on each correction until clear.

### Completion Condition
- Stage persisted as submitted with all required rules satisfied.

---

## FL-003 — Measurement Entry + Correction
**Story Mapping:** US-003

### Preconditions
- Current step type is `measurement`.
- Measurement schema (unit/format/precision/range) is available.

### Happy Path
1. Judge opens measurement step.
2. App displays input, unit, and allowed format.
3. Judge enters value.
4. App validates numeric format/precision/range.
5. Value is saved as draft.
6. Judge can revise value before stage submission.

### Validation Failures
- Non-numeric input.
- Precision exceeds allowed digits.
- Value out of allowed range.

### Recovery Path
- Show immediate field-level validation message.
- Keep previous valid value until new value passes.
- Allow retry without losing other step data.

### Completion Condition
- Valid measurement value is stored and stage-level validation no longer flags this step.

---

## FL-004 — Evidence Attach/Remove + Required-Proof Blocking
**Story Mapping:** US-004

### Preconditions
- Current step supports or requires evidence.
- Attachment metadata service is available.

### Happy Path
1. Judge opens evidence step.
2. Judge adds attachment.
3. App stores attachment metadata and displays it.
4. Judge may remove/replace attachment before submit.
5. On stage submit, app verifies required-proof rules.

### Validation Failures
- Required evidence missing.
- Attachment metadata write fails.
- Attachment removed causing required minimum to fail.

### Recovery Path
- Show attach error and preserve step context.
- Allow retry attach action.
- Block submit with clear required-proof message until satisfied.

### Completion Condition
- Evidence rules satisfied and attachment metadata persisted for submission snapshot.

---

## FL-005 — Team Switch + Context Restore
**Story Mapping:** US-006

### Preconditions
- Judge has an active team session.
- At least one other team is available.

### Happy Path
1. Judge initiates team switch.
2. App checks dirty state for current team.
3. If dirty, app prompts to save/confirm switch.
4. App persists current draft snapshot.
5. App loads selected team’s existing session or starts new one.
6. Judge sees selected team-only context.

### Validation Failures
- Draft snapshot persistence fails.
- Selected team session unavailable.

### Recovery Path
- Cancel switch and keep judge on current team with error feedback.
- Offer retry save + switch.
- If target unavailable, return to team selector without context mutation.

### Completion Condition
- Current app context is fully switched and isolated to selected team.

---

## FL-006 — Historical Submission Inspection
**Story Mapping:** US-007

### Preconditions
- User has access to team history view.
- Submission snapshots exist for selected team/test case.

### Happy Path
1. User opens history list.
2. App shows submissions ordered by timestamp.
3. User selects a submission.
4. App displays read-only detail: stage/step outcomes, notes, evidence references.

### Validation Failures
- No history records available.
- Snapshot detail retrieval fails.

### Recovery Path
- Show empty state with clear message when no records exist.
- Show recoverable load error with retry when retrieval fails.
- Never open editable controls in history mode.

### Completion Condition
- User successfully views immutable historical submission detail.

---

## Gate B Checklist (Flows -> Screens)
- Every required flow defined (`FL-001`..`FL-006`).
- Each flow includes: preconditions, happy path, validation failures, recovery path, completion condition.
- Each flow mapped to Phase 1 story IDs.
