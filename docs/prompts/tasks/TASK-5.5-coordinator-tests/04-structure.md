# Structure Prompt

Given this task and approach:

Task: `5.5 Add coordinator tests for opening a test case, opening a test step, applying edits, and returning edits to the parent test case.`

Approach: `<paste approach>`

Define the implementation structure.

Include:

- Models, coordinators, fixtures, and tests involved
- Dependencies between immutable test case content, mutable test step drafts, and parent test case draft aggregation
- Minimal coordinator route/state shape
- Test helper fixtures needed for one test case with ordered steps
- Suggested commit boundaries
- Risks from coupling this slice to future app/session coordinators
- Risks from adding behavior that belongs in tasks `5.6` or `7.x`
- How this task fits into current OpenSpec task `5.5`

Prefer the existing MVC + Coordinators + Services architecture while keeping the coordinator narrowly testable.

Commit rule:

Each commit title must be 52 characters or fewer and must not intentionally leave the project in a non-compiling state at commit boundaries.
