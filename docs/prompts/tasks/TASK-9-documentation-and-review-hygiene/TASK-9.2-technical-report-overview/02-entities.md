# Entities Prompt

For this task:

Task: `9.2 Write a technical report style overview of the inspection event architecture, recheck behavior, testing approach, accessibility conventions, and localization conventions.`

Identify the core entities and relationships.

Include:

- Domain models, services, coordinators, views, documentation, fixtures, or validation artifacts involved
- State boundaries and ownership
- Persistence or accessibility identifiers where relevant
- Test or validation entities
- PR review entities: files, commit boundaries, and reviewer concerns

Likely files or targets:

- Technical report docs

Call out what can be validated through Swift Testing, static review, dedicated UI automation, or user-run manual validation.

Context:

- Macro-task: TASK#9 Documentation and Review Hygiene
- Subtask: TASK#9.2
- Expected PR title: `TASK#9.2: Technical Report Overview`
- Feature branch: `codex/inspection-event-docs-review-hygiene`
- Suggested task branch: `codex/inspection-event-docs-review-hygiene-9-2-technical-report-overview`
- Operation summary: Write the technical report overview for architecture, rechecks, testing, accessibility, and localization.
- Likely files or targets: Technical report docs
- Validation: Review against OpenSpec design and specs.
- Split trigger: Split if report becomes a broad architecture rewrite.
- Common instructions:
- Use YAML frontmatter for title, domain, feature, status, owners, source files, and related scenarios.
- Write documentation in technical report style when explaining architecture and workflow.
- Keep tutorials short and task-oriented.
- Every implementation PR uses Summary, Scope, Notes, and Validation.
- Include manual validation notes, test command output, linked feature scenarios, and squash-merge guidance.
- Keep one feature branch and one PR per major feature by default.
- Split into task branches only when review context becomes too broad.
