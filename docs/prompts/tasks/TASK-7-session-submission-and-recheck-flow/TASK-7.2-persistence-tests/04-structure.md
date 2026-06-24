# Structure Prompt

For this task:

Task: `7.2 Add failing persistence tests for storing each in-progress test case as its own JSON file under FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask), scoped by event, team, session, stage, and test case ID.`

Define the file and PR structure.

Include:

- Files to inspect first
- Files that may be added or edited
- Test files or validation artifacts
- PR description sections: `Summary`, `Scope`, `Notes`, `Validation`
- Commit boundaries
- Split criteria

Prompt folder:

`docs/prompts/tasks/TASK-7-session-submission-and-recheck-flow/TASK-7.2-persistence-tests`

Expected task files or targets:

- Persistence tests
- temp directory helpers
- draft path helpers

Recommended commit title:

`7.2 persistence tests`

Return the proposed file tree and explain which files are implementation, tests, fixtures, docs, or validation artifacts.
