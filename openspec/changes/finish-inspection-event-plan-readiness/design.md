# Design

## Readiness Gate

This change is a short cleanup and verification plan, not a feature implementation. Treat it as the closeout bridge between the completed Task 9 organization pass and Task 10 UX work.

The gate has four checks:

1. Current OpenSpec plan status is understood.
2. PR #59 has no unresolved review comments or requested changes.
3. The branch still builds after any review fixes.
4. Remaining manual validation tasks are documented before Task 10 starts.

## GitHub Review Policy

Use the GitHub connector or `gh` to inspect:

- PR metadata and mergeability.
- Top-level PR comments.
- Review submissions.
- Inline review threads, including resolved state.

If review feedback exists, classify it as:

- Required fix: behavior, build, test, or documentation correctness issue.
- Follow-up: useful but outside Task 9 readiness.
- Non-actionable: acknowledgements or stale comments.

Required fixes must be completed on the Task 9 branch before Task 10 starts. Follow-ups must be added to the relevant later OpenSpec plan.

## Validation

The minimum verification is:

- `xcodebuild build` for the app target after any change.
- Focused tests only when review feedback touches behavior, persistence, validation, or coordinator logic.
- Manual validation notes for unfinished earlier plan tasks where automation does not exist yet.

## Handoff

The final output of this change should be a short handoff note in the implementation PR or local summary that says:

- Which GitHub feedback was reviewed.
- Which fixes were made.
- Which remaining tasks were deferred and where.
- Whether Task 10 design review may begin.

