# TASK#7.2 SPDD Prompt Run

Task: `7.2 Add failing persistence tests for storing each in-progress test case as its own JSON file under FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask), scoped by event, team, session, stage, and test case ID.`

Purpose: Add failing Swift Testing coverage for per-test-case Application Support JSON draft storage.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Persistence tests; temp directory helpers; draft path helpers
- Validation: Swift Testing with isolated temporary Application Support root.
- Split trigger: Split if storage layout helpers become reusable infrastructure.

Expected PR title:

`TASK#7.2: Persistence Tests`

Branch:

`codex/inspection-event-session-flow-7-2-persistence-tests`

Common instructions:

- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
