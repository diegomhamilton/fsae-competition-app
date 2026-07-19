# Structure Prompt

For this task:

Task: `10.3 Refactor judge navigation so Sessions, Team, and Stage are the top-level landmarks, remove the standalone Case tab, and make Stage contain the case UI with dominant next-action and focused one-step editing.`

Define the file and PR structure.

Include:

- Files to inspect first
- Files that may be added or edited
- Test files or validation artifacts
- PR description sections: `Summary`, `Scope`, `Notes`, `Validation`
- Commit boundaries
- Split criteria

Prompt folder:

`docs/prompts/tasks/TASK-10-local-stored-judge-experience-ux-follow-up/TASK-10.3-guided-navigation`

Expected task files or targets:

- ContentTabsView
- ProposedScreen
- AppCoordinator / InspectionExecutionCoordinator route handling
- FullStageView
- TestCaseView
- view state
- tests

Recommended commit title:

`10.3 guided navigation`

Return the proposed file tree and explain which files are implementation, tests, fixtures, docs, or validation artifacts.
