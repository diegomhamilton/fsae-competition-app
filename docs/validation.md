---
title: Inspection validation
domain: inspection-event
status: active
owners: [Tester, Developer]
source_files: [tools/ui-validation/checkpoint.sh, docs/known-issues.md]
related_scenarios: [Confirm results only after persistence, Correct and submit a stage, Preserve draft isolation]
---

# Validation

## Current result

Last verified application source: `8a7705f0953075f235a68f4e9fe42179cfcfd529`, 25 October 2026. A clean export passed **155 test definitions / 158 executed cases**, zero failures/skips, in 21 Swift Testing suites. Xcode 26.6 (17F113), FSAE UI Review simulator, iPhone 17 Pro / iOS 26.2, x86_64. The Debug test action built the app. This result applies to that source; refresh it when application source changes. No current Release or arm64 result is asserted.

Command, run from a clean export of the application source:

```sh
xcodebuild test \
  -project FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist.xcodeproj \
  -scheme FSAEInspectionChecklist \
  -destination 'platform=iOS Simulator,id=<available-review-simulator-id>' \
  -derivedDataPath /tmp/FSAEReviewDerivedData \
  -resultBundlePath /tmp/FSAEReview.xcresult \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
xcrun xcresulttool get test-results summary --path /tmp/FSAEReview.xcresult --format json
```

Discover a destination first; use a fresh result-bundle path for each run. Preserve unrelated local project edits by validating an explicit source export when needed. Keep command logs/result bundles in temporary local output or PR validation evidence, not committed documentation archives.

A separate temporary diagnostic replay for the [notes/outcome issue](known-issues.md#outcome-editing-after-notes) ran 16 tests: 15 existing tests passed and the added expectation failed. It does not alter or invalidate the clean-source suite result. Callback tests do not prove native gesture/focus behavior.

## Required manual checks

- [ ] Native Back, completed and cancelled interactive pop from queue/focus/review/correction routes; original selection and values retained.
- [ ] Multiple corrections preserve review position, flags and return targets.
- [ ] Notes-to-outcome editing, keyboard Done, distinct notes/measurement values and persisted field identity.
- [ ] Rapid leave/re-entry during debounce, save, confirmation and photo import; no stale overwrites or unintended advancement.
- [ ] Real save/import failure and retry; cancelled picker/retake retains previous evidence.
- [ ] Compact widths, large Dynamic Type, long criteria and keyboard-open layouts.
- [ ] VoiceOver controls, result/flag cues, blocker navigation and next-test context.
- [ ] Reduce Motion playback and tab restoration during native navigation.
- [ ] Camera permissions/capture and storage failure on hardware.
- [ ] Relaunch/resume after drafts and submission, immutable snapshots and team/session/stage isolation.
- [ ] Outdoor physical-device ergonomics and controlled attached/standalone Add Team comparison.

No item above is checked solely because a fixture renders or a unit suite passes. Keep deferred reset/history/team-switch/recheck/sticker behavior separate from current-flow validation.

## Simulator and visual workflow

Use [checkpoint helpers](../tools/ui-validation/README.md). Configure `FSAE_DEVELOPER_DIR` using `xcode-select -p`, a retained DerivedData location and an explicitly discovered `FSAE_SIMULATOR_ID`. Run status/version/destinations/devices, then the needed build or test command. Testing already builds the product.

Run boot, readiness, install, launch and capture as separate observable steps. Use supported DEBUG scenario arguments from `InspectionSnapshotHarness`; `queue-return` programmatically replays an animated return inside native tabs. Fixtures isolate judge data but do not establish touch-flow correctness.

Keep captures in temporary output, inspect them visually after the boot/blank-screen gate, and replace stale evidence in the PR when source changes. Do not accumulate baseline galleries, phase journals or PDF collections in the repository. Physical-device installation requires separate coordination.
