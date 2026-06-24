# Norms Prompt

Apply the project norms to this task:

Task: `5.5 Add coordinator tests for opening a test case, opening a test step, applying edits, and returning edits to the parent test case.`

Check the proposed work against these norms:

- TDD for coordinator behavior
- Swift Testing for unit tests
- Swift 6 and Concurrency-first boundaries
- SwiftUI views with small local UI state only
- Coordinators own flow state and user intents; services own validation and persistence
- Structured `Strings` enums for any new user-visible text
- Stable accessibility identifiers separate from localized labels
- Feature scenarios as acceptance backbone
- One feature branch / PR per major slice unless review context gets too broad
- Branch name must be `codex/task-5.5-coordinator-tests`
- PR title must be `TASK#5.5: Add test case coordinator tests`
- Each task must be split into reviewable commits with commit titles of 52 characters or fewer
- Commits must not intentionally leave the project in a non-compiling state
- Do not build the code automatically; capture build and validation as user-run unless the user explicitly asks the agent to build
- Manual validation notes belong in the PR description

Return any adjustments needed before implementation.

Recommended commit title candidates:

- `Add TASK#5.5 prompt run`
- `Add test case coordinator tests`
- `Add test case draft handoff`
