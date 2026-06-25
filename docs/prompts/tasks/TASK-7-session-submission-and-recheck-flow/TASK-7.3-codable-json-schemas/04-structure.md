# Structure Prompt

For this task:

Task: `7.3 Define Codable JSON schemas for test case draft files and immutable submitted test case/stage snapshot files, including schema version, event ID, team ID, session ID, stage ID, test case ID, updated timestamp, outcomes, notes, measurements, evidence metadata, validation summary, and recheck references.`

Define the file and PR structure.

Include:

- Files to inspect first
- Files that may be added or edited
- Test files or validation artifacts
- PR description sections: `Summary`, `Scope`, `Notes`, `Validation`
- Commit boundaries
- Split criteria

Prompt folder:

`docs/prompts/tasks/TASK-7-session-submission-and-recheck-flow/TASK-7.3-codable-json-schemas`

Expected task files or targets:

- Draft and snapshot model files
- schema fixtures
- model tests

Recommended commit title:

`7.3 codable json schemas`

Return the proposed file tree and explain which files are implementation, tests, fixtures, docs, or validation artifacts.
