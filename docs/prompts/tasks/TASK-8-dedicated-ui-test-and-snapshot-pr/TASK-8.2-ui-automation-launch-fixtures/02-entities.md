# Entities Prompt

For this task:

Task: `8.2 Add dedicated UI automation launch fixtures for positive, negative, and edge states using mock data.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- UI test launch config
- mock fixture loader
- test helpers

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#8 Dedicated UI Test and Snapshot PR
- Subtask: TASK#8.2
- Expected PR title: `TASK#8.2: UI Automation Launch Fixtures`
- Feature branch: `codex/inspection-event-ui-tests`
- Suggested task branch: `codex/inspection-event-ui-tests-8-2-ui-automation-launch-fixtures`
- Operation summary: Add launch fixtures for positive, negative, and edge UI automation states.
- Likely files or targets: UI test launch config; mock fixture loader; test helpers
- Validation: Launch app into each fixture state on selected simulator.
- Split trigger: Split if fixture plumbing touches app runtime code and project config together.
- Common instructions:
- Start only after accessibility identifiers and stable navigation hooks exist.
- Keep UI automation in a dedicated PR separate from implementation slices.
- Prefer stable identifiers over localized labels.
- Use mock launch fixtures for positive, negative, and edge states.
- Use Swift Testing-compatible snapshot coverage for high-value stable states.
- Map coverage back to feature scenarios and personas.
- Split if project-file setup, fixtures, flow tests, and baselines exceed 10 files or become hard to review together.
