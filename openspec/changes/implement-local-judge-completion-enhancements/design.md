# Design

## Scope

Implement Task 10.8 through Task 10.13 after the Task 10 design review and UX foundation slice are complete.

In scope:

- Camera/photo capture entry point for evidence-required steps.
- Evidence metadata persistence in test case JSON drafts.
- Recheck service for failed test case lifecycle.
- Sticker eligibility calculation from submitted stages and open rechecks.
- Egress stopwatch timing with start, stop, reset, manual override, validation, persistence, and accessible announcements.
- Focused tests and final manual validation.

Out of scope:

- Remote sync.
- Production authentication.
- Final full-resolution media storage policy beyond approved local metadata and referenced file metadata.
- Dedicated broad UI automation unless required hooks are missing.

## Storage Boundaries

Evidence capture should persist metadata that can be validated and restored. If captured files are stored locally, the design-review-approved policy must define where they live and how deletion behaves. The JSON draft should not assume future cloud sync or public export.

Submitted snapshots remain immutable. Rechecks reference failed submitted test cases and later accepted review records rather than mutating historical submissions.

## Stopwatch Model

Egress timing should support:

- Idle.
- Running.
- Stopped with recorded value.
- Manual override.
- Reset.
- Validation against allowed range.

Timing controls must be accessible and announce start, stop, reset, and validation result.

## Verification

Use focused tests for:

- Evidence metadata persistence and validation.
- Recheck creation and closure.
- Sticker eligibility with open and closed rechecks.
- Stopwatch measurement parsing, range validation, persistence, and manual override.

Manual validation must cover start, resume after relaunch, submit, blocked submit, team switch, recheck, sticker eligibility, per-test-case JSON files, team submission folders, evidence metadata, and stopwatch timing.

