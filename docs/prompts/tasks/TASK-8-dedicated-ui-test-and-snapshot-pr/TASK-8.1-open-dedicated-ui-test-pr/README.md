# TASK#8.1 SPDD Prompt Run

Task: `8.1 Open a dedicated UI test PR after accessibility identifiers and stable navigation hooks exist.`

Purpose: Open the dedicated UI automation and snapshot PR only after stable accessibility and navigation prerequisites exist.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: PR description; prompt docs; prerequisite checklist
- Validation: Static prerequisite review against TASK#6 and TASK#7 outputs.
- Split trigger: Split if prerequisites are incomplete and require implementation fixes.

Expected PR title:

`TASK#8.1: Open Dedicated UI Test PR`

Branch:

`codex/inspection-event-ui-tests-8-1-open-dedicated-ui-test-pr`

Common instructions:

- Start only after accessibility identifiers and stable navigation hooks exist.
- Keep UI automation in a dedicated PR separate from implementation slices.
- Prefer stable identifiers over localized labels.
- Use mock launch fixtures for positive, negative, and edge states.
- Use Swift Testing-compatible snapshot coverage for high-value stable states.
- Map coverage back to feature scenarios and personas.
- Split if project-file setup, fixtures, flow tests, and baselines exceed 10 files or become hard to review together.
