---
title: "Next pass - Dynamic focused execution"
domain: inspection-event
feature: focused-execution-interactions
status: ready-for-implementation
owners: [planner-agent, developer-agent, tester-agent]
source_files:
  - openspec/changes/technical-inspection-event-development-plan/tasks.md
  - docs/simplified-ui-redesign-plan.md
related_scenarios:
  - Record and confirm an inspection result
  - Return from review to the current test
  - Correct an inspection result without losing the judge's place
approved: 2026-10-15
---

# Next pass - Dynamic focused execution

[[../Home|Vault home]] · [[../Plan.canvas|Vertical plan]]

The judge approved the proposed interaction ideas on 15 October 2026. The latest approval expands the immediate implementation scope to improvements 1-10: larger controls and screen usage, transforming inputs, navigation continuity, coordinated next-test transitions, large measurement entry, photo previews, and whole-card review editing. See [[../Workflow/Implementation-plan-1-to-10|the PR and implementation plan]]. Milestone **11. UI Improvements**, tasks **11.8** and **11.9**, is the authoritative task tracker. This note records scope and acceptance criteria; it does not claim these changes are implemented. The existing 36-page snapshot PDF remains the reference baseline.

## Current focus - task 11.8

### 11.8.1 Transforming inputs with larger, rounded controls

Reference pages: **6-8 and 15**.

- Give the current task and result interaction more of the available screen. Use the rounded visual language from the queue on pages **22-24**; preserve the queue's existing appearance.
- Starting typography targets: test title 30-34 pt, criteria 24-28 pt, action labels 22-24 pt. Primary controls approximately 80-96 pt high. Adapt to compact screens, the keyboard, and Dynamic Type rather than forcing fixed heights or filling space with extra information.
- The Pass/Fail area transitions in place into a concise editable result and Save & next test. Keep the interaction area stable rather than shrinking after selection. A large tappable result replaces reliance on a tiny pencil.
- Add note expands into a rounded editor in place and focuses the keyboard. While editing, the outcome becomes a compact result pill; competing outcome controls yield to the editor.
- Done above the keyboard contracts the editor into a tappable note preview and restores the primary action when the required data is valid. Retain the + access alongside the result component.
- Selecting Fail opens the same editor automatically with Reason for failure. Optional notes remain hidden until requested. Autosave, retry, required fields, and explicit result confirmation retain their existing semantics.

### 11.8.2 Preserve position through queue and review

Reference pages: **22-25 and 27-30**.

- Opening the queue brings the current test into view and identifies it with text/icon as well as color. Keep the rounded groups, the judge's expansion choices, and the selected test context.
- Returning from a correction restores the review scroll position and briefly identifies the changed result.
- Back to test restores the same vehicle, case, step, and values. Leaving review through another route must not reuse a stale correction target.
- A resolved flag leaves Needs attention only once the corrected result is valid, saved, and confirmed. The update must not jump the judge to the top of review.

### 11.8.3 Coordinate saved feedback, progress, and next test

Reference pages: **17-19**.

- After successful persistence, show a brief saved confirmation and transition the next test into the same work area. Update the progress indicator with the transition.
- Saving failures preserve the current input and selection, expose retry, and never advance. Repeated taps cannot skip a test or confirm another result.
- The final test opens review; corrections return to review rather than continuing the normal queue.
- Keep motion brief. Respect Reduce Motion, retain text/icon status cues and VoiceOver context, and avoid adding artificial save delays for animation.

## Interaction extensions - task 11.9

Tasks 11.9.1-11.9.3 are now included in the current implementation scope (improvements 8-10). Tasks 11.9.4-11.9.8 remain accepted follow-ups (improvements 11-15). The table retains the full backlog and acceptance direction.

| Task | Follow-up | Reference | Acceptance direction |
| --- | --- | --- | --- |
| 11.9.1 | Large measurement interaction | Pages 10-11 | Prominent value/unit, tap to enter, immediate range feedback. Keep the required judge outcome explicit. |
| 11.9.2 | Photo action becomes preview | Pages 12-13, 34-35 | Capture action becomes a thumbnail with View/Retake; cancellation keeps the previous evidence until replacement succeeds. |
| 11.9.3 | Larger, whole-card review targets | Page 25 | Tap anywhere on a result card to correct it; larger result/status labels; retain rounded cards and final submission access. |
| 11.9.4 | Contextual + actions | Pages 14 and 30 | Suggest Add note/Edit note or Add another photo from actual recorded content. Preserve exceptional actions. |
| 11.9.5 | Undo after advancement | Pages 18-19 | Brief Undo returns to the prior result with values intact; no deletion of saved data or historical submission snapshots. |
| 11.9.6 | Haptic feedback | Pages 6-7 and 16-18 | Distinguish selection, successful recording, and failure where supported; maintain visible and accessible equivalents. |
| 11.9.7 | Inline expandable instructions | Pages 4 and 6 | Expand short criteria in place; retain View details for complete rules; never hide applicable safety warnings. |
| 11.9.8 | Press feedback on large controls | Pages 6-7 and 22 | Subtle compression on press, no layout jump or delayed action, and reduced-motion support. |

Existing milestone tasks 11.1-11.4 remain in place. These follow-ups refine their interactions; they do not mark broad validation, labels, or evidence-import scope complete. Team switching and deferred concurrency work remain excluded.

## Implementation boundaries and validation

Keep presentation and animations in focused SwiftUI components, navigation/return positions in the stage coordinator, and existing draft/storage ownership in the execution coordinator and services. Replace each predecessor in the same feature commit and include its task snapshots, following the existing build workflow.

Before implementation, define behavior checks for note expansion/collapse without losing input, failure-required notes, persistence-gated advancement, review-return targets, and scroll/section restoration. Use distinct note and measurement values to check field identity. Capture stable input, editor, ready, queue-return, review-return, and next-test states. Verify compact widths, larger text, keyboard visibility, reduced motion, and VoiceOver context; screenshots alone do not prove those interactions.

No new app implementation, screenshots, PDF revision, or runtime validation is included in this planning update.
