# Entities Prompt

For this task:

Task: `9.3 Add short tutorials for adding a new inspection JSON fixture, adding a new validation rule, adding a new accessibility identifier, and adding a new persona scenario.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- Tutorial docs

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#9 Documentation and Review Hygiene
- Subtask: TASK#9.3
- Expected PR title: `TASK#9.3: Tutorials`
- Feature branch: `codex/inspection-event-docs-review-hygiene`
- Suggested task branch: `codex/inspection-event-docs-review-hygiene-9-3-tutorials`
- Operation summary: Add short operational tutorials for common inspection-event extension tasks.
- Likely files or targets: Tutorial docs
- Validation: Each tutorial has prerequisite, steps, validation, and follow-up.
- Split trigger: Split tutorials if examples require code changes.
- Common instructions:
- Use YAML frontmatter for title, domain, feature, status, owners, source files, and related scenarios.
- Write documentation in technical report style when explaining architecture and workflow.
- Keep tutorials short and task-oriented.
- Every implementation PR uses Summary, Scope, Notes, and Validation.
- Include manual validation notes, test command output, linked feature scenarios, and squash-merge guidance.
- Keep one feature branch and one PR per major feature by default.
- Split into task branches only when review context becomes too broad.
