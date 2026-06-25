# TASK#8.3 SPDD Prompt Run

Task: `8.3 Add dedicated UI automation coverage for login, session selector, stage navigation, test case navigation, test step editing, validation blocking, team switching, recheck review, and sticker eligibility.`

Purpose: Add dedicated UI automation flows for the full judge inspection journey.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: UI automation test files; launch fixtures; accessibility IDs
- Validation: UI automation run on selected simulator.
- Split trigger: Split by flow family if file count exceeds 10 or failures are hard to isolate.

Expected PR title:

`TASK#8.3: UI Automation Flows`

Branch:

`codex/inspection-event-ui-tests-8-3-ui-automation-flows`

Common instructions:

- Start only after accessibility identifiers and stable navigation hooks exist.
- Keep UI automation in a dedicated PR separate from implementation slices.
- Prefer stable identifiers over localized labels.
- Use mock launch fixtures for positive, negative, and edge states.
- Use Swift Testing-compatible snapshot coverage for high-value stable states.
- Map coverage back to feature scenarios and personas.
- Split if project-file setup, fixtures, flow tests, and baselines exceed 10 files or become hard to review together.
