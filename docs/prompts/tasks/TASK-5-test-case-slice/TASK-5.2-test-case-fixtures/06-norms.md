# Norms Prompt

Apply the project norms to this task:

Task: `5.2 Add mock JSON fixtures for representative test cases with one step, multiple steps, measurement steps, required evidence, failed notes, and energized badges.`

Check the proposed work against these norms:

- Keep the implementation fixture-only unless a minimal loader update is required for validity
- TDD for model behavior remains owned by TASK#5.1 and TASK#5.3
- Swift 6 and Concurrency-first boundaries if any Swift loader code is touched
- Stable fixture IDs and order fields separate from display strings
- Feature scenarios as acceptance backbone
- PR titles must start with `TASK#{TASK NUMBER}:`
- Each task must be split into reviewable commits with commit titles of 52 characters or fewer
- Commits must not intentionally leave the project in a non-compiling state
- Do not build the code automatically; capture build and validation as user-run unless the user explicitly asks the agent to build
- Manual validation notes belong in the PR description

Return any adjustments needed before implementation.

Expected PR title:

`TASK#5.2: Add test case JSON fixtures`

Recommended commit title candidates:

- `Add TASK#5.2 prompt run`
- `Add test case JSON fixtures`
- `Mark TASK#5.2 fixtures complete`
