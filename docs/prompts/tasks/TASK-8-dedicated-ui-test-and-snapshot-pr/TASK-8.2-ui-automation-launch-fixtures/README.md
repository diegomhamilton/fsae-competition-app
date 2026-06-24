# TASK#8.2 SPDD Prompt Run

Task: `8.2 Add dedicated UI automation launch fixtures for positive, negative, and edge states using mock data.`

Purpose: Add launch fixtures for positive, negative, and edge UI automation states.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: UI test launch config; mock fixture loader; test helpers
- Validation: Launch app into each fixture state on selected simulator.
- Split trigger: Split if fixture plumbing touches app runtime code and project config together.

Expected PR title:

`TASK#8.2: UI Automation Launch Fixtures`

Branch:

`codex/inspection-event-ui-tests-8-2-ui-automation-launch-fixtures`

Common instructions:

- Start only after accessibility identifiers and stable navigation hooks exist.
- Keep UI automation in a dedicated PR separate from implementation slices.
- Prefer stable identifiers over localized labels.
- Use mock launch fixtures for positive, negative, and edge states.
- Use Swift Testing-compatible snapshot coverage for high-value stable states.
- Map coverage back to feature scenarios and personas.
- Split if project-file setup, fixtures, flow tests, and baselines exceed 10 files or become hard to review together.
