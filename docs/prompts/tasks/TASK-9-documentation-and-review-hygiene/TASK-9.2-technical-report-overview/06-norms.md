# Norms Prompt

Apply the project norms to this task:

Task: `9.2 Write a technical report style overview of the inspection event architecture, recheck behavior, testing approach, accessibility conventions, and localization conventions.`

Check the proposed work against these norms:

- Use YAML frontmatter for title, domain, feature, status, owners, source files, and related scenarios.
- Write documentation in technical report style when explaining architecture and workflow.
- Keep tutorials short and task-oriented.
- Every implementation PR uses Summary, Scope, Notes, and Validation.
- Include manual validation notes, test command output, linked feature scenarios, and squash-merge guidance.
- Keep one feature branch and one PR per major feature by default.
- Split into task branches only when review context becomes too broad.
- Use Swift Testing for unit and integration checks.
- Keep dedicated UI automation in the TASK#8 PR.
- Use stable accessibility identifiers instead of localized labels for UI automation.
- Keep PR titles in the `TASK#9.2: <summary>` format.
- Keep commit titles 52 characters or fewer.
- Keep manual validation honest: `not run` is better than unsupported claims.

Return any adjustments needed before implementation.

Expected PR title:

`TASK#9.2: Technical Report Overview`
