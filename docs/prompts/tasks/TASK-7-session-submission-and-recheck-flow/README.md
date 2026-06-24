# TASK#7 SPDD Operations Prompt Run

Task group: Session, Submission, and Recheck Flow

Purpose: plan the local stored inspection workflow from mock login through session restore, per-test-case draft persistence, stage submission snapshots, rechecks, and sticker eligibility.

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
- TASK#7.10 recheck service
- TASK#7.11 sticker eligibility
- TASK#7.12 manual validation

Expected feature branch:

`codex/inspection-event-session-flow`

Default PR strategy:

Keep one feature PR for the session flow only if the branch remains reviewable. Split into task branches when coordinator, persistence, store, submission, recheck, and UI binding changes exceed 10 files or mix unrelated review contexts.

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
- `TASK-7.10-recheck-service/`
- `TASK-7.11-sticker-eligibility/`
- `TASK-7.12-manual-validation/`

