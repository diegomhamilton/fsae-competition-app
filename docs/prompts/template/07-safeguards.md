# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `<paste task>`

Plan: `<paste operations>`

Review for:

- Scope creep
- Missing failing tests
- Accessibility gaps
- Localization gaps
- Unsafe concurrency or shared mutable state
- JSON fixture/schema assumptions
- Incomplete validation paths
- PR review risk
- Manual validation omissions

Return blockers first, then recommendations, then a final go/no-go.
