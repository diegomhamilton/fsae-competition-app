# TASK#7.9 SPDD Prompt Run

Task: `7.9 Implement SubmissionSnapshotService for immutable stage submission snapshots backed by the team submission JSON folder.`

Purpose: Implement immutable stage submission snapshot creation backed by team submission JSON folders.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: SubmissionSnapshotService; submission models; tests
- Validation: Swift Testing for snapshot creation, immutability, and team path placement.
- Split trigger: Split if persistence cleanup or recheck creation gets mixed in.

Expected PR title:

`TASK#7.9: Submission Snapshot Service`

Branch:

`codex/inspection-event-session-flow-7-9-submission-snapshot-service`

Common instructions:

- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
