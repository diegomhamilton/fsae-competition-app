# Entities Prompt

For this task:

Task: `8.5 Add snapshot tests for test step, test case, stage list, validation blocked, recheck required, and sticker eligible states where practical.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- Snapshot test target/config/baselines

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#8 Dedicated UI Test and Snapshot PR
- Subtask: TASK#8.5
- Expected PR title: `TASK#8.5: Snapshot Tests`
- Feature branch: `codex/inspection-event-ui-tests`
- Suggested task branch: `codex/inspection-event-ui-tests-8-5-snapshot-tests`
- Operation summary: Add Swift Testing-compatible snapshots for high-value inspection states.
- Likely files or targets: Snapshot test target/config/baselines
- Validation: Swift Testing snapshot command with controlled simulator/runtime.
- Split trigger: Split if snapshot dependency or baselines create large diffs.
- Common instructions:
- Start only after accessibility identifiers and stable navigation hooks exist.
- Keep UI automation in a dedicated PR separate from implementation slices.
- Prefer stable identifiers over localized labels.
- Use mock launch fixtures for positive, negative, and edge states.
- Use Swift Testing-compatible snapshot coverage for high-value stable states.
- Map coverage back to feature scenarios and personas.
- Split if project-file setup, fixtures, flow tests, and baselines exceed 10 files or become hard to review together.
