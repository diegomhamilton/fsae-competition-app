---
title: "Phase 2 — Result input, +, and autosave"
phase: 2
status: planned
tags: [phase, swiftui, input, persistence]
---

# Phase 2 — Result input, +, and autosave

[[../Home|Project home]] · [[../Plan.canvas|Vertical plan]]

## Goal

One result component presents the controls required by the current step. Once the judge completes valid input, the status area becomes **Save & next test**, with the result remaining editable. A **+** button sits beside the component and opens optional notes/evidence and supported secondary actions.

## Tasks

- [ ] Extract the result component with input driven by the official step schema.
- [ ] Support Pass/Fail, measurements with units and numeric keyboard, and required evidence as the schema specifies.
- [ ] Reveal required failure notes before the result is ready to confirm.
- [ ] Replace the status/action area in place when the result is ready; retain an edit path.
- [ ] Consolidate notes/evidence and existing More actions into **+**.
- [ ] Autosave field values; hide routine successful-save badges.
- [ ] Show transient saving/confirmation feedback, preserve input on failure, and advance only after successful persistence.
- [ ] Capture each relevant result and recovery state.

## Component and predecessor

Remove the independent competing Pass/Fail/save arrangement, separate Add notes or evidence and More actions links, persistent Saved on this device badge, and initial missing-outcome error in the same component commit. This task describes behavior rather than prescribing exactly three internal states.

## Required evidence

- Unanswered result input and the ready-to-save result at the same location.
- Failure outcome with required note entry.
- Measurement input with its unit; evidence/photo input where supported.
- Open **+** menu and one revealed optional input.
- Save failure with preserved result and retry, followed by successful advancement when testable.
- Focused automated checks for readiness, persistence gating, and preserved input rather than tests mirroring view code.

## Completion record

- Commit: pending
- Snapshots: pending
- Validation: pending

Previous: [[01-focus-context-and-details|Phase 1]]. Next: [[03-queue-and-review-return|Phase 3 — Queue and review return]].
