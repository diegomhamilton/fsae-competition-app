# Active inspection backlog

Current behavior is documented in [the system map](../../../docs/system-map.md) and [inspection UI](../../../docs/simplified-ui-redesign-plan.md). This list contains unfinished work and acceptance gaps; completed execution logs are removed. Stable task numbers remain for references. Never check an item solely from a screenshot or an older test result.

## Current defects and validation

- [ ] Fix and verify the notes/outcome edit-mode conflict in [known issues](../../../docs/known-issues.md#outcome-editing-after-notes).
- [ ] Complete the applicable [manual validation checklist](../../../docs/validation.md#required-manual-checks).
- [ ] Investigate the debugger-attached Add Team stall only with a controlled same-installed-app comparison; internal cause remains unresolved.
- [ ] Resolve actor-isolation warnings in the separate concurrency scope.

## 8. Dedicated UI Test and Snapshot PR

- [ ] 8.1 Open a dedicated UI test PR after accessibility identifiers and stable navigation hooks exist.
- [ ] 8.2 Add dedicated UI automation launch fixtures for positive, negative, and edge states using mock data.
- [ ] 8.3 Add dedicated UI automation coverage for login, session selector, stage navigation, test case navigation, test step editing, validation blocking, team switching, recheck review, and sticker eligibility.
- [ ] 8.4 Add dedicated UI automation checks that assert required controls and statuses are accessible by stable identifiers rather than localized labels.
- [ ] 8.5 Add snapshot tests for test step, test case, stage list, validation blocked, recheck required, and sticker eligible states where practical.
- [ ] 8.6 Document UI test coverage back to the `.feature` scenarios and personas.

## 10. Local Full-Suite Session Version

- [ ] 10.7 Add session recovery and history: reset an active session with confirmation, preserve past completed executions, show past sessions with start/end timestamps, and document the validation path for checking past executions.

## 11. UI Improvements

- [ ] 11.0.1 Validate Add Team creation with distinct display-name/car-number values, persistence and accessible dismissal.
- [ ] 11.1 Make validation blockers actionable by tapping or selecting a blocker to focus the missing outcome, note, measurement, or evidence control, then persist the correction immediately to the test case JSON draft.
- [ ] 11.2 Review `Pending` semantics so incomplete required steps are represented as derived draft state rather than a confusing judge decision.
- [ ] 11.3 Clarify notes and evidence states with labels such as "Add Evidence", "1 Evidence", "Required Evidence Missing", "Add Note", and "Edit Note".
- [ ] 11.4 Complete remaining evidence scope: Files import, media-storage policy and native camera/library permission, cancellation and failure validation.
- [ ] 11.5 Implement `RecheckService` so failed test cases create open recheck items and accepted reviews close them.
- [ ] 11.6 Implement sticker eligibility calculation from submitted stages and open rechecks.
- [ ] 11.7 Add stopwatch-style timing support for egress-test measurement steps.
- [ ] 11.8 Finish native interaction and accessibility validation of focused execution; use the current validation checklist.
- [ ] 11.9 Complete deferred interaction extensions (improvements 11–15).
  - [ ] 11.9.4 Contextual + actions derived from existing notes/evidence.
  - [ ] 11.9.5 Brief Undo after advancement that preserves saved values and immutable history.
  - [ ] 11.9.6 Distinct selection, saved, and failure haptics with visible/accessibility equivalents.
  - [ ] 11.9.7 Inline expandable criteria alongside complete toolbar rule details; safety warnings always visible.
  - [ ] 11.9.8 Subtle press feedback for large controls with no layout jumps and reduced-motion support.

## 12. Parking Lot

- [ ] 12.1 Refactor step metadata layout to avoid wrapping/truncation in compact widths and larger Dynamic Type.
- [ ] 12.2 Add dedicated UI automation launch fixtures, workflow automation, accessibility identifier assertions, snapshots, and coverage documentation.
- [ ] 12.4 Map EV safety context by test case and step, including energized warnings, accumulator-related cautions, and required PPE guidance where the inspection content or rule metadata supports it.
- [ ] 12.5 Design expandable rule reference presentation so long references such as `EV.7.5.5 / BR.4.6.1.1` can be reviewed without squeezing into small chips.
- [ ] 12.6 Add optional "Why this matters" or inspection hint content for dense EV checks, starting with temperature monitoring and maintenance plug foolproof-connection cases.
- [ ] 12.7 Decide whether EV-specific hints live in bundled inspection JSON, a separate reviewed metadata file, or future remote event content before implementing UI.
