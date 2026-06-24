# TASK#8.5 SPDD Prompt Run

Task: `8.5 Add snapshot tests for test step, test case, stage list, validation blocked, recheck required, and sticker eligible states where practical.`

Purpose: Add Swift Testing-compatible snapshots for high-value inspection states.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: Snapshot test target/config/baselines
- Validation: Swift Testing snapshot command with controlled simulator/runtime.
- Split trigger: Split if snapshot dependency or baselines create large diffs.

Expected PR title:

`TASK#8.5: Snapshot Tests`

Branch:

`codex/inspection-event-ui-tests-8-5-snapshot-tests`

Common instructions:

- Start only after accessibility identifiers and stable navigation hooks exist.
- Keep UI automation in a dedicated PR separate from implementation slices.
- Prefer stable identifiers over localized labels.
- Use mock launch fixtures for positive, negative, and edge states.
- Use Swift Testing-compatible snapshot coverage for high-value stable states.
- Map coverage back to feature scenarios and personas.
- Split if project-file setup, fixtures, flow tests, and baselines exceed 10 files or become hard to review together.
