# Entities Prompt

For this task:

Task: `9.1 Add or update documentation files with YAML frontmatter for title, domain, feature, status, owners, source files, and related scenarios.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- Docs markdown files

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#9 Documentation and Review Hygiene
- Subtask: TASK#9.1
- Expected PR title: `TASK#9.1: Documentation Frontmatter`
- Feature branch: `codex/inspection-event-docs-review-hygiene`
- Suggested task branch: `codex/inspection-event-docs-review-hygiene-9-1-documentation-frontmatter`
- Operation summary: Add or update documentation frontmatter for indexing and review traceability.
- Likely files or targets: Docs markdown files
- Validation: Frontmatter inspection and rg checks.
- Split trigger: Split if frontmatter touches unrelated document families.
- Common instructions:
- Use YAML frontmatter for title, domain, feature, status, owners, source files, and related scenarios.
- Write documentation in technical report style when explaining architecture and workflow.
- Keep tutorials short and task-oriented.
- Every implementation PR uses Summary, Scope, Notes, and Validation.
- Include manual validation notes, test command output, linked feature scenarios, and squash-merge guidance.
- Keep one feature branch and one PR per major feature by default.
- Split into task branches only when review context becomes too broad.
