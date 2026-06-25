# Structure Prompt

Given this task and approach:

Task: `5.6 Refactor the existing stage step card pattern into a test case view that renders ordered steps and validation summaries.`

Approach: `<paste approach>`

Define the implementation structure.

Include:

- Models, views, coordinators, services, fixtures, and tests involved
- Dependencies between test case content, step draft state, validation state, and UI rendering
- Ownership of keyboard focus and the keyboard dismissal affordance in repeated step note inputs
- Where structured `Strings` enums and accessibility identifiers belong
- Suggested commit boundaries
- Risks from coupling, ordering, or over-refactoring stage flows
- How this task fits into the current OpenSpec slice

Prefer the existing MVC + Coordinators + Services architecture.

Commit rule:

Each commit title must be 52 characters or fewer and must not intentionally leave the project in a non-compiling state.

Commit title candidates:

- `Add TASK#5.6 prompt run`
- `Add test case view`
- `Add test case view tests`

Build policy:

Do not build automatically. The user owns build and validation unless they explicitly ask Codex to run it.
