# Operations Prompt

Given this task, approach, and structure:

Task: `6.1 Add failing unit tests for InspectionStage, InspectionSection, bundled JSON decoding, display ordering, stable IDs, unsupported step type errors, and malformed JSON failures.`

Structure: `<paste structure>`

Decompose this into concrete, reviewable operations.

For each operation, include:

- Exact action
- Expected files or test targets
- Verification command or manual check
- Build ownership: user-run
- Manual validation notes to capture when the user builds or inspects locally
- Commit boundary and proposed commit title of 52 characters or fewer
- Whether the operation can be committed without breaking compilation
- Done condition

Required operation coverage:

- Confirm the branch is `codex/task-6.1-stage-content-tests` and based on latest local `develop` if available.
- Create this SPDD prompt folder first and commit it with title `Add TASK#6.1 prompt run`.
- Push the branch after the prompt-only commit and before implementation edits.
- Read OpenSpec proposal, design, tasks, specs, the `.feature` file, prompt template/example, relevant source models, existing unit tests, and bundled JSON resources.
- Treat TASK#5.7 as completed prior context; TASK#6.1 should extend from validated Test Case view behavior into stage content tests.
- Inspect current model/test drift before writing tests, especially `displayOrder` and draft helper APIs expected by existing tests.
- Add failing Swift Testing unit tests for `InspectionStage` identity, title, display order, ordered sections, and stable stage IDs.
- Add failing Swift Testing unit tests for `InspectionSection` identity, title, display order, ordered test cases, and stable section IDs.
- Add failing Swift Testing unit tests for bundled JSON decoding of Garage, Body, Chassis, EV, Egress, and Rain in official display order.
- Add failing Swift Testing unit tests for ordered test cases, ordered steps, rule references, badges, step types, and content preservation inside decoded stages.
- Add failing Swift Testing unit tests for unsupported step type errors.
- Add failing Swift Testing unit tests for malformed JSON or missing required-field errors.
- Avoid implementing `InspectionContentService`, JSON-backed stage views, energized badge derivation, structured view strings, accessibility identifiers, or manual validation docs in this task.
- Do not update the OpenSpec task checkbox unless TASK#6.1 is actually complete.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#6.1: Add stage content tests`
