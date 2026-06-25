# Entities Prompt

For this task:

Task: `8.3 Add dedicated UI automation coverage for login, session selector, stage navigation, test case navigation, test step editing, validation blocking, team switching, recheck review, and sticker eligibility.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- UI automation test files
- launch fixtures
- accessibility IDs

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#8 Dedicated UI Test and Snapshot PR
- Subtask: TASK#8.3
- Expected PR title: `TASK#8.3: UI Automation Flows`
- Feature branch: `codex/inspection-event-ui-tests`
- Suggested task branch: `codex/inspection-event-ui-tests-8-3-ui-automation-flows`
- Operation summary: Add dedicated UI automation flows for the full judge inspection journey.
- Likely files or targets: UI automation test files; launch fixtures; accessibility IDs
- Validation: UI automation run on selected simulator.
- Split trigger: Split by flow family if file count exceeds 10 or failures are hard to isolate.
- Common instructions:
- Start only after accessibility identifiers and stable navigation hooks exist.
- Keep UI automation in a dedicated PR separate from implementation slices.
- Prefer stable identifiers over localized labels.
- Use mock launch fixtures for positive, negative, and edge states.
- Use Swift Testing-compatible snapshot coverage for high-value stable states.
- Map coverage back to feature scenarios and personas.
- Split if project-file setup, fixtures, flow tests, and baselines exceed 10 files or become hard to review together.
