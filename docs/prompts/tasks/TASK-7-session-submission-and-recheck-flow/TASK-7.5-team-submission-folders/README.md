# TASK#7.5 SPDD Prompt Run

Task: `7.5 Group each team's submission files in a team-specific Application Support folder so submitted snapshots, rechecks, and sticker eligibility can be reviewed without mixing team contexts.`

Purpose: Add team-specific submission folder grouping so snapshots, rechecks, and sticker eligibility do not mix team contexts.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Persistence layout policy; path builders; submission tests
- Validation: Swift Testing path scoping checks proving no team mixing.
- Split trigger: Split if submission path policy affects recheck and sticker services at the same time.

Expected PR title:

`TASK#7.5: Team Submission Folders`

Branch:

`codex/inspection-event-session-flow-7-5-team-submission-folders`

Common instructions:

- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
