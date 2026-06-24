# Entities Prompt

For this task:

Task: `8.1 Open a dedicated UI test PR after accessibility identifiers and stable navigation hooks exist.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- PR description
- prompt docs
- prerequisite checklist

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#8 Dedicated UI Test and Snapshot PR
- Subtask: TASK#8.1
- Expected PR title: `TASK#8.1: Open Dedicated UI Test PR`
- Feature branch: `codex/inspection-event-ui-tests`
- Suggested task branch: `codex/inspection-event-ui-tests-8-1-open-dedicated-ui-test-pr`
- Operation summary: Open the dedicated UI automation and snapshot PR only after stable accessibility and navigation prerequisites exist.
- Likely files or targets: PR description; prompt docs; prerequisite checklist
- Validation: Static prerequisite review against TASK#6 and TASK#7 outputs.
- Split trigger: Split if prerequisites are incomplete and require implementation fixes.
- Common instructions:
- Start only after accessibility identifiers and stable navigation hooks exist.
- Keep UI automation in a dedicated PR separate from implementation slices.
- Prefer stable identifiers over localized labels.
- Use mock launch fixtures for positive, negative, and edge states.
- Use Swift Testing-compatible snapshot coverage for high-value stable states.
- Map coverage back to feature scenarios and personas.
- Split if project-file setup, fixtures, flow tests, and baselines exceed 10 files or become hard to review together.
