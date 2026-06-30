# TASK#9.7 SPDD Prompt Run

Task: `9.7 Add the Tentpole 3 organization plan with the target App, Common, Features, and TestSupport tree, plus a dry-run table mapping current files to proposed destinations, import risks, ownership risks, and validation checks.`

Purpose: make future source organization reviewable before any move-only implementation pass starts.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: organization docs, Task 9 prompt docs, and references to `docs/prompts/tasks/TASK-12-spdd-2026-06-29-tentpoles/03-approach.md`.
- Validation: dry-run table covers destination, ownership, imports, risk, and validation checks for each future file group.
- Split trigger: split if the organization plan expands into persistence migration decisions, Stage-first UX decisions, or source movement.

Expected PR title:

`TASK#9.7: Document Organization Dry Run`

Branch:

`codex/inspection-event-docs-review-hygiene-9-7-organization-dry-run`

Common instructions:

- Treat this as Tentpole 3 organization work.
- Prioritize the TASK#12 Organization Design target tree.
- Do not move source files, edit Xcode project settings, or rename symbols in this task.
- Call out high-risk files such as `InspectionModels.swift`, `TestCaseJSONPersistenceService.swift`, `AppCoordinators.swift`, and `ContentView.swift`.
- Keep validation mapped to existing tests and manual checks before implementation tasks begin.
