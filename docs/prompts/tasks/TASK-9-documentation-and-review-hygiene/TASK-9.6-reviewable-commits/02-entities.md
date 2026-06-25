# Entities Prompt

For this task:

Task: `9.6 Split tasks across distinct commits so each completed task or tightly related task pair has a reviewable checkpoint.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- Commit plan docs
- PR notes

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#9 Documentation and Review Hygiene
- Subtask: TASK#9.6
- Expected PR title: `TASK#9.6: Reviewable Commits`
- Feature branch: `codex/inspection-event-docs-review-hygiene`
- Suggested task branch: `codex/inspection-event-docs-review-hygiene-9-6-reviewable-commits`
- Operation summary: Define task-sized commit guidance so each checkpoint is reviewable.
- Likely files or targets: Commit plan docs; PR notes
- Validation: Commit list maps to tasks and validation.
- Split trigger: Split branches if commits are still too hard to review in one PR.
- Common instructions:
- Use YAML frontmatter for title, domain, feature, status, owners, source files, and related scenarios.
- Write documentation in technical report style when explaining architecture and workflow.
- Keep tutorials short and task-oriented.
- Every implementation PR uses Summary, Scope, Notes, and Validation.
- Include manual validation notes, test command output, linked feature scenarios, and squash-merge guidance.
- Keep one feature branch and one PR per major feature by default.
- Split into task branches only when review context becomes too broad.
