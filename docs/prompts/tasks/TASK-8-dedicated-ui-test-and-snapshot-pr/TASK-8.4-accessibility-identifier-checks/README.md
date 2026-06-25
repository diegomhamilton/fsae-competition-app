# TASK#8.4 SPDD Prompt Run

Task: `8.4 Add dedicated UI automation checks that assert required controls and statuses are accessible by stable identifiers rather than localized labels.`

Purpose: Assert controls and statuses by stable accessibility identifiers rather than localized labels.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: UI automation assertions; accessibility ID helpers
- Validation: Tests fail when required identifiers are missing or unstable.
- Split trigger: Split if app code needs identifier fixes.

Expected PR title:

`TASK#8.4: Accessibility Identifier Checks`

Branch:

`codex/inspection-event-ui-tests-8-4-accessibility-identifier-checks`

Common instructions:

- Start only after accessibility identifiers and stable navigation hooks exist.
- Keep UI automation in a dedicated PR separate from implementation slices.
- Prefer stable identifiers over localized labels.
- Use mock launch fixtures for positive, negative, and edge states.
- Use Swift Testing-compatible snapshot coverage for high-value stable states.
- Map coverage back to feature scenarios and personas.
- Split if project-file setup, fixtures, flow tests, and baselines exceed 10 files or become hard to review together.
