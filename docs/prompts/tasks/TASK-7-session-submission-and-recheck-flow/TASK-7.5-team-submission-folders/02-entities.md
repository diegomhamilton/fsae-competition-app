# Entities Prompt

For this task:

Task: `7.5 Group each team's submission files in a team-specific Application Support folder so submitted snapshots, rechecks, and sticker eligibility can be reviewed without mixing team contexts.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- Persistence layout policy
- path builders
- submission tests

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#7 Session, Submission, and Recheck Flow
- Subtask: TASK#7.5
- Expected PR title: `TASK#7.5: Team Submission Folders`
- Feature branch: `codex/inspection-event-session-flow`
- Suggested task branch: `codex/inspection-event-session-flow-7-5-team-submission-folders`
- Operation summary: Add team-specific submission folder grouping so snapshots, rechecks, and sticker eligibility do not mix team contexts.
- Likely files or targets: Persistence layout policy; path builders; submission tests
- Validation: Swift Testing path scoping checks proving no team mixing.
- Split trigger: Split if submission path policy affects recheck and sticker services at the same time.
- Common instructions:
- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
