# TASK#7.11 SPDD Prompt Run

Task: `7.11 Implement sticker eligibility calculation from submitted stages and open rechecks.`

Purpose: Implement sticker eligibility calculation from submitted stages and unresolved rechecks after submission/recheck services are backed by persisted data.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Eligibility service/model; tests
- Validation: Swift Testing matrix for submitted, missing, open-recheck, and eligible states.
- Split trigger: Split if eligibility display UI or coordinator/view draft integration changes are included.

Expected PR title:

`TASK#7.11: Sticker Eligibility`

Branch:

`codex/inspection-event-session-flow-7-11-sticker-eligibility`

Common instructions:

- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Do not use eligibility work to backfill coordinator/view draft save/restore.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
