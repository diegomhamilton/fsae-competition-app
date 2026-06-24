# TASK#5.3 SPDD Prompt Run

Task: `5.3 Implement test case models and draft state composition from test step drafts.`

Branch: `codex/task-5.3-test-case-models`

Expected PR title:

`TASK#5.3: Implement test case models`

Purpose: implement the model layer for inspection test cases by composing ordered `InspectionTestStep` content with draft step results, while leaving validation service rules and UI refactors to later tasks.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Build policy:

Do not build automatically. The user owns build and validation unless they explicitly ask Codex to run it.

Commit title candidates:

- `Add test case domain models`
- `Compose test case draft state`
- `Add test case model tests`
