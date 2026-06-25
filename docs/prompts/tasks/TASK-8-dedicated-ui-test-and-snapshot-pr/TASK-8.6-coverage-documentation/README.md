# TASK#8.6 SPDD Prompt Run

Task: `8.6 Document UI test coverage back to the .feature scenarios and personas.`

Purpose: Document UI automation and snapshot coverage against feature scenarios and personas.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Coverage docs; PR validation notes
- Validation: Scenario/persona mapping review.
- Split trigger: Keep docs separate if test PR is already large.

Expected PR title:

`TASK#8.6: Coverage Documentation`

Branch:

`codex/inspection-event-ui-tests-8-6-coverage-documentation`

Common instructions:

- Start only after accessibility identifiers and stable navigation hooks exist.
- Keep UI automation in a dedicated PR separate from implementation slices.
- Prefer stable identifiers over localized labels.
- Use mock launch fixtures for positive, negative, and edge states.
- Use Swift Testing-compatible snapshot coverage for high-value stable states.
- Map coverage back to feature scenarios and personas.
- Split if project-file setup, fixtures, flow tests, and baselines exceed 10 files or become hard to review together.
