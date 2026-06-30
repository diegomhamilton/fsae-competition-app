# TASK#8 Common Instructions

Use these instructions across every TASK#8 operation prompt.

- Start only after accessibility identifiers, stable navigation hooks, and TASK#7 coordinator/view store-backed draft save/restore exist.
- Keep UI tests in a dedicated PR separate from implementation slices.
- Prefer stable identifiers over localized labels.
- Use mock launch fixtures for positive, negative, and edge states.
- Keep snapshot coverage high-value and narrow: test step, test case, stage list, validation blocked, recheck required, and sticker eligible states.
- Document coverage back to feature scenarios and personas.
- Keep PR descriptions in `Summary`, `Scope`, `Notes`, and `Validation` format.
- Split if UI test setup causes project-file churn plus test-flow churn in the same PR.
