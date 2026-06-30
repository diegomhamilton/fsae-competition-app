# TASK#7.12 SPDD Prompt Run

Task: `7.12 Manually validate start, resume after app relaunch, submit, blocked submit, team switch, recheck, sticker eligibility, per-test-case JSON files, and team submission folders against the .feature file.`

Purpose: Prepare and run manual validation for the full local session, submission, recheck, sticker, and JSON-folder workflow, starting with proof that coordinators/views use InspectionEventStore for draft save/restore.

Tentpole scope: this task is executed under Tentpole 2 because it validates the full stored judge workflow. The `7.12` ID is retained for OpenSpec traceability.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Manual checklist; PR validation note; feature scenario map
- Validation: User-run app evidence only; static review can prepare checklist. Confirm draft save/restore before validating submission/recheck/sticker flows.
- Split trigger: Keep as documentation/validation PR if implementation evidence is not available.

Expected PR title:

`TASK#7.12: Manual Validation`

Branch:

`codex/inspection-event-session-flow-7-12-manual-validation`

Common instructions:

- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Do not mark submission/recheck validation complete if coordinator/view draft save/restore is not wired.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
