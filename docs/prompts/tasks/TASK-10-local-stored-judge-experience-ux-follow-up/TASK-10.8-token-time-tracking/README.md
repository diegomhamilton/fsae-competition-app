# TASK#10.8 SPDD Prompt Run

Task: `10.8 Track actual token and time usage for each Task 10 PR while completing Task 10. Update task-10-full-suite-session-plan.xlsx with estimated tokens, actual input/output/total tokens, estimated time, actual time, branch, PR, and completion notes for 10.4 through 10.7.`

Purpose: finish the local full-suite session run with auditable token/time actuals for each completed Task 10 PR.

Branch: `codex/task-10-8-token-time-tracking`

Expected PR title: `TASK#10.8: Token and Time Tracking`

Run prompts in this order:

1. Requirements: read spreadsheet skill instructions, common instructions, completed PR data for TASK#10.4 through TASK#10.7, and current workbook structure.
2. Entities: identify workbook rows, estimated/actual token fields, time fields, branch, PR URL, SHA, and completion note columns.
3. Approach: use `load_workspace_dependencies` and `@oai/artifact-tool` to edit the workbook; do not use alternate spreadsheet authoring libraries.
4. Structure: preserve existing workbook formatting and formulas while filling actual values.
5. Operations: update workbook, visually verify workbook output, update OpenSpec checkbox, commit, push, and open a draft PR automatically.
6. Norms: cite branch/PR values exactly and keep token notes concise.
7. Safeguards: do not fabricate unavailable token values; mark unavailable fields explicitly with a completion note.

Agent/skill/tool mapping: use `../common-instructions.md`; spreadsheet work must also follow the installed Spreadsheets skill.

Validation:

- Workbook includes actual input, output, total tokens, actual time, branch, PR, and notes for completed TASK#10.4 through TASK#10.7 rows.
- Workbook opens and renders legibly after export.
- Final PR notes identify any unavailable metrics rather than guessing.
