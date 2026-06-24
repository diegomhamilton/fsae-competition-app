# TASK#7.3 SPDD Prompt Run

Task: `7.3 Define Codable JSON schemas for test case draft files and immutable submitted test case/stage snapshot files, including schema version, event ID, team ID, session ID, stage ID, test case ID, updated timestamp, outcomes, notes, measurements, evidence metadata, validation summary, and recheck references.`

Purpose: Define Codable v1 draft and submission snapshot schemas with explicit IDs, timestamps, validation, evidence, and recheck references.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Draft and snapshot model files; schema fixtures; model tests
- Validation: Swift Testing Codable round-trip and malformed-payload checks.
- Split trigger: Split if schema migration or compatibility logic grows beyond initial v1 shape.

Expected PR title:

`TASK#7.3: Codable JSON Schemas`

Branch:

`codex/inspection-event-session-flow-7-3-codable-json-schemas`

Common instructions:

- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
