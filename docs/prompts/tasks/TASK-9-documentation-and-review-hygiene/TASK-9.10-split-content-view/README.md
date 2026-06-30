# TASK#9.10 SPDD Prompt Run

Task: `9.10 Split ContentView.swift into smaller root composition, tab, binding, and empty-state files without changing behavior.`

Purpose: make root app composition easier to review by separating top-level tab declarations, coordinator bindings, loading/fallback states, and empty flow presentation.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: `ContentView.swift`, new App/root view composition files, `EmptyFlowState`, `ProposedScreen`, coordinator binding helpers, coordinator/view tests.
- Validation: build/tests pass; the top-level tabs and current route behavior remain unchanged.
- Split trigger: split further if tab composition, dependency wiring, and UI state extraction produce a broad diff.

Expected PR title:

`TASK#9.10: Split Content View`

Branch:

`codex/inspection-event-docs-review-hygiene-9-10-split-content-view`

Common instructions:

- Treat this as Tentpole 3 organization work.
- Preserve current top-level behavior even if later Tentpole 2 work will hide Case/Step tabs.
- Do not mix Stage-first UX changes, persistence wiring, or Task 10 copy/layout changes into this split.
- Keep `ContentView` or its replacement as a thin root composition surface.
- Run coordinator/view-related tests and perform a quick manual navigation smoke check before marking complete.
