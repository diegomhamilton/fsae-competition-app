---
title: "Phase 3 — Queue and review return"
phase: 3
status: queue-complete
tags: [phase, swiftui, navigation, review]
---

# Phase 3 — Queue and review return

[[../Home|Project home]] · [[../Plan.canvas|Vertical plan]]

## Goal

Keep the dense overview on the queue and final review screens. A judge can preview review, return to the same test and step with values intact, edit a result, and return to review.

## Tasks

- [ ] Extract queue and review presentation into dedicated UI components.
- [x] Provide a clear queue entry and test selection without restoring the dense execution screen.
- [ ] Offer early review through **+** and automatically open it after the final test.
- [ ] Add **Back to test** that restores the current vehicle, test, step, and draft values.
- [ ] Preserve a return path to review after correcting an individual result.
- [ ] Keep final submission distinct from previewing review.
- [ ] Capture queue, review, correction, and return states.

## Component and predecessor

Replace the old queue sheet and review detour with the extracted components in their own feature commits. Remove the always-visible Review results link from focus. During focus, remove session/vehicle management navigation from the execution surface; preserve it in the overview flow. Do not re-enable disabled session switching.

## Required evidence

- Pre-run queue and selecting the next test.
- Early review with **Back to test** visible.
- Restored focus screen with the same entered result.
- Editing from review with an explicit route back to review.
- End-of-run review, including incomplete or flagged results when present.
- Focused checks for navigation restoration and draft preservation.

## Completion record

- Queue commit: the feature checkpoint containing [[../Snapshots/03-queue/README|three queue captures]].
- Review commit: pending.
- Validation: queue build passed; five result-status checks passed. Review and full-scheme checks follow.

Previous: [[02-result-input-and-additions|Phase 2]]. Next: [[04-final-checks-and-pdf|Phase 4 — Final checks and snapshot PDF]].
