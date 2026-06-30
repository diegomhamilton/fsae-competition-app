# TASK#7 SPDD Operations Prompt Run

Task group: Session and Submission Flow Foundation

Purpose: plan the local stored inspection workflow from mock login through session restore, per-test-case draft persistence, and stage submission snapshots.

Scope note: TASK#7 now owns the technical foundation through TASK#7.9. TASK#7.10, TASK#7.11, and TASK#7.12 are still traceable by their original IDs, but they belong to Tentpole 2 because recheck closure, sticker eligibility, and full manual validation are judge-facing workflow/UX completion work.

Current integration note: `InspectionEventStore` may already exist in code, but Task 7 is not functionally complete until app coordinators and SwiftUI views use it for store-backed draft save/restore. Keep that first integration PR separate from stage submission wiring.

Primary prompt:

- `05-operations-summary.md`

Shared instruction highlight:

- `common-instructions.md`

Subtasks covered:

- TASK#7.1 coordinator tests
- TASK#7.2 persistence tests
- TASK#7.3 Codable JSON schemas
- TASK#7.4 actor-isolated JSON persistence service
- TASK#7.5 team-specific submission folders
- TASK#7.6 coordinator PR split
- TASK#7.7 actor-isolated event store
- TASK#7.8 coordinator-backed views
- TASK#7.9 submission snapshot service

Moved to Tentpole 2:

- TASK#7.10 recheck service
- TASK#7.11 sticker eligibility
- TASK#7.12 manual validation

Expected feature branch:

`codex/inspection-event-session-flow`

Default PR strategy:

Keep one feature PR for the session flow foundation only if the branch remains reviewable. Split into task branches when coordinator, persistence, store, submission, and UI binding changes exceed 10 files or mix unrelated review contexts. The first integration PR should link coordinators/views to store-backed draft save/restore and explicitly leave broader judge-facing recheck/sticker/manual validation work to Tentpole 2.

Child prompt runs:

- `TASK-7.1-coordinator-tests/`
- `TASK-7.2-persistence-tests/`
- `TASK-7.3-codable-json-schemas/`
- `TASK-7.4-json-persistence-service/`
- `TASK-7.5-team-submission-folders/`
- `TASK-7.6-coordinators/`
- `TASK-7.7-inspection-event-store/`
- `TASK-7.8-coordinator-backed-views/`
- `TASK-7.9-submission-snapshot-service/`

Tentpole 2 continuation prompt runs:

- `TASK-7.10-recheck-service/`
- `TASK-7.11-sticker-eligibility/`
- `TASK-7.12-manual-validation/`
