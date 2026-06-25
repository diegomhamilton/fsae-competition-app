# TASK#9.4 SPDD Prompt Run

Task: `9.4 Ensure each implementation PR uses the PR 1 description template with Summary, Scope, Notes, and Validation, including manual validation notes, test command output, linked .feature scenarios, and squash-merge guidance.`

Purpose: Standardize implementation PR descriptions around Summary, Scope, Notes, Validation, scenario links, and squash guidance.

Run these prompts in order:

1. `01-requirements.md`
2. `02-entities.md`
3. `03-approach.md`
4. `04-structure.md`
5. `05-operations.md`
6. `06-norms.md`
7. `07-safeguards.md`

Operation focus:

- Likely files or targets: PR templates; docs; prompt files
- Validation: PR description checklist review.
- Split trigger: Keep separate from code PRs when possible.

Expected PR title:

`TASK#9.4: PR Description Template`

Branch:

`codex/inspection-event-docs-review-hygiene-9-4-pr-description-template`

Common instructions:

- Use YAML frontmatter for title, domain, feature, status, owners, source files, and related scenarios.
- Write documentation in technical report style when explaining architecture and workflow.
- Keep tutorials short and task-oriented.
- Every implementation PR uses Summary, Scope, Notes, and Validation.
- Include manual validation notes, test command output, linked feature scenarios, and squash-merge guidance.
- Keep one feature branch and one PR per major feature by default.
- Split into task branches only when review context becomes too broad.
