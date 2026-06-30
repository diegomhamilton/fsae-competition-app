# Implement Local Judge Completion Enhancements

## Why

Once the UX foundation is clear, the local stored judge experience needs the remaining completion features from Task 10: camera/photo evidence metadata, rechecks, sticker eligibility, egress stopwatch timing, and final validation coverage.

These features are grouped separately because they affect storage, submission history, validation, and operational completion semantics more deeply than the UX foundation polish.

## What Changes

- Add camera/photo capture support for evidence-required steps while persisting metadata in the local test case JSON draft.
- Implement recheck creation and closure for failed test cases.
- Implement sticker eligibility from submitted stages and open rechecks.
- Add stopwatch-style timing for egress measurement steps with manual override and accessibility announcements.
- Complete focused automated and manual validation for the full local stored judge experience.

## Impact

- Persistence schemas may need additive metadata fields.
- Submission/recheck/sticker services and tests will change.
- Step measurement UI will gain timing controls.
- Full media storage remains constrained by the design review storage policy.

