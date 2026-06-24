# TASK#7.4 SPDD Prompt Run

Task: `7.4 Implement an actor-isolated JSON file persistence service that creates the Application Support folder tree, writes each test case draft atomically, deletes or archives stale draft files after submission, and restores drafts after app relaunch.`

Purpose: Implement actor-isolated JSON draft persistence with atomic writes, folder creation, stale draft cleanup, and relaunch restore.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Persistence service; file helpers; persistence tests
- Validation: Swift Testing for actor-isolated writes, restore, atomic replacement, and cleanup.
- Split trigger: Split from schemas if implementation touches more than persistence service plus tests.

Expected PR title:

`TASK#7.4: JSON Persistence Service`

Branch:

`codex/inspection-event-session-flow-7-4-json-persistence-service`

Common instructions:

- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
