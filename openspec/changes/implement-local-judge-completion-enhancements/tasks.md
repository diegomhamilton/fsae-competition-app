## 1. Prepare Completion Slice

- [ ] 1.1 Confirm design review and UX foundation implementation are complete.
- [ ] 1.2 Review persistence schemas for additive evidence, recheck, sticker, and timing data needs.
- [ ] 1.3 Add failing tests for evidence metadata, rechecks, sticker eligibility, and stopwatch timing.

## 2. Evidence Capture Metadata

- [ ] 2.1 Add camera/photo capture support for evidence-required steps within the approved storage policy.
- [ ] 2.2 Persist captured file metadata with the test case JSON draft.
- [ ] 2.3 Support evidence metadata removal and ensure validation blocks again when required evidence is removed.
- [ ] 2.4 Verify evidence controls remain accessible and state labels match the UX foundation vocabulary.

## 3. Rechecks and Sticker Eligibility

- [ ] 3.1 Implement `RecheckService` so failed test cases create open recheck items.
- [ ] 3.2 Allow accepted judge reviews to close recheck items without mutating historical submission snapshots.
- [ ] 3.3 Implement sticker eligibility calculation from required submitted stages and open rechecks.
- [ ] 3.4 Surface recheck and sticker eligibility state through the active team and stage/test case UI.

## 4. Egress Stopwatch Timing

- [ ] 4.1 Add stopwatch controls for egress measurement steps: start, stop, reset, and manual override.
- [ ] 4.2 Persist stopwatch/manual measurement values to the local test case JSON draft.
- [ ] 4.3 Validate stopwatch values against allowed measurement ranges.
- [ ] 4.4 Add accessible announcements for start, stop, reset, saved value, and validation errors.

## 5. Final Validation

- [ ] 5.1 Run focused tests for validation, persistence, submission, recheck, sticker eligibility, and stopwatch timing.
- [ ] 5.2 Manually validate start, resume after app relaunch, submit, blocked submit, team switch, recheck, sticker eligibility, per-test-case JSON files, team submission folders, evidence metadata, and stopwatch timing against the `.feature` file.
- [ ] 5.3 Record PR validation notes and remaining storage-policy follow-ups.

