# Norms Prompt

Apply the project norms to this task:

Task: `6.6 Add structured Strings enums and stable accessibility identifiers to the stage and test case list files.`

Check the proposed work against these norms:

- Display strings use structured per-file constant enums
- Accessibility labels, hints, and values use the same localizable string structure as visible text
- Stable accessibility identifiers are separate from localized labels
- Identifiers must be based on stable IDs, not display titles
- VoiceOver can understand progress, blockers, validation, submit state, and energized safety
- Status and safety states must not rely on color alone
- Dedicated UI automation and snapshots belong to the dedicated UI test PR
- Branch name is `codex/task-6.6-stage-accessibility-strings`
- PR titles must start with `TASK#{TASK NUMBER}:`, using `TASK#6.6: Add stage accessibility IDs`
- Commit titles must be 52 characters or fewer
- Do not build automatically; capture build and validation as user-run unless explicitly asked

Return any adjustments needed before implementation.

Expected PR title:

`TASK#6.6: Add stage accessibility IDs`

Recommended commit title candidates:

- `Add TASK#6.6 prompt run`
- `Add stage accessibility IDs`
- `Structure stage view strings`
