# TASK#9 Common Instructions

Use these instructions across every TASK#9 operation prompt.

- Treat TASK#9 as Tentpole 3: code organization, documentation, prompt taxonomy, and review hygiene.
- Prioritize the TASK#12 Organization Design target tree before source moves: `App`, `Common`, `Features`, and `TestSupport`.
- Document dry-run file destinations, import risks, ownership risks, and validation checks before moving or splitting source files.
- Move or split one ownership boundary at a time and keep behavior-neutral organization PRs separate from UX, persistence, or feature behavior changes.
- Use YAML frontmatter for title, domain, feature, status, owners, source files, and related scenarios.
- Write technical documentation in a report style with explicit architecture, recheck, testing, accessibility, and localization sections.
- Keep tutorials short and task-oriented.
- Every implementation PR should use `Summary`, `Scope`, `Notes`, and `Validation`.
- Include manual validation notes, test command output, linked feature scenarios, and squash-merge guidance.
- Keep one feature branch and one PR per major feature by default.
- Split into task branches only when review context becomes too broad.
- Keep commits task-sized so each completed task or tightly related pair is a reviewable checkpoint.
