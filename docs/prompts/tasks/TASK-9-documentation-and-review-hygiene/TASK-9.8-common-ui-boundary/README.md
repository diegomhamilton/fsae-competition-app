# TASK#9.8 SPDD Prompt Run

Task: `9.8 Perform the first behavior-neutral organization pass for Common/UI, starting with DesignSystem.swift and KeyboardDismissBar.swift, preserving public symbols and existing UI behavior.`

Purpose: establish the low-risk `Common/UI` boundary before moving feature-owned models, services, coordinators, or views.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: `DesignSystem.swift`, `KeyboardDismissBar.swift`, project references if the Xcode project requires path updates, and UI/build validation notes.
- Validation: build/tests pass; existing design system symbols, keyboard dismissal behavior, imports, previews, and visible styling remain unchanged.
- Split trigger: split if project file updates, folder creation, and Swift source moves become hard to review in one PR.

Expected PR title:

`TASK#9.8: Establish Common UI Boundary`

Branch:

`codex/inspection-event-docs-review-hygiene-9-8-common-ui-boundary`

Common instructions:

- Treat this as Tentpole 3 organization work.
- Keep the pass move-only or split-only; no UX redesign, style changes, or keyboard behavior changes belong here.
- Preserve public symbols and compatibility imports where needed.
- Do not move inspection content, persistence, submission, Stage/Case/Step views, `AppCoordinators.swift`, or `ContentView.swift` in this task.
- Record the exact build/test command used before marking complete.
