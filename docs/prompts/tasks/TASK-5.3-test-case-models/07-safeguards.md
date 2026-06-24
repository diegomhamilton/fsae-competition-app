# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `5.3 Implement test case models and draft state composition from test step drafts.`

Plan: `<paste operations>`

Review for:

- Scope creep into TASK#5.4 validation service rules
- Scope creep into TASK#5.6 UI refactors
- Missing failing tests or insufficient model coverage
- Lost ordered step behavior
- Dropped rule references or unstable IDs
- Draft aggregation that ignores existing `StepResult` / `TestStepDraft` concepts
- Progress that treats context-only or optional steps incorrectly
- Blocker counts that imply complete validation before TASK#5.4
- Unsafe concurrency or shared mutable state
- JSON fixture/schema assumptions
- PR review risk from mixing prompt-only and implementation commits
- Commit titles longer than 52 characters
- PR title not starting with `TASK#5.3:`
- Automatic build/test execution despite the user-run build policy
- Manual validation omissions

Return blockers first, then recommendations, then a final go/no-go.

Expected PR title:

`TASK#5.3: Implement test case models`
