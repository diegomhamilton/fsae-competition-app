# TASK#7.10 SPDD Prompt Run

Task: `7.10 Implement RecheckService so failed test cases create open recheck items and accepted reviews close them.`

Purpose: Implement recheck lifecycle from failed test case to open item to accepted review closure.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: RecheckService; recheck models; tests
- Validation: Swift Testing for failed case creation, open state, accepted review closure, and references.
- Split trigger: Split if UI review flow is introduced with service behavior.

Expected PR title:

`TASK#7.10: Recheck Service`

Branch:

`codex/inspection-event-session-flow-7-10-recheck-service`

Common instructions:

- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
