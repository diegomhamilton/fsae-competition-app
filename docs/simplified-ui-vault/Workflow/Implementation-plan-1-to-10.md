---
title: "Implementation and PR plan - improvements 1 to 10"
domain: inspection-event
feature: dynamic-focused-execution
status: implemented-in-draft-prs
owners: [architect-agent, planner-agent, developer-agent, tester-agent, documenter-agent]
approved_scope: 2026-10-15
source_files:
  - openspec/changes/technical-inspection-event-development-plan/tasks.md
  - docs/simplified-ui-vault/Phases/05-dynamic-interactions.md
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/TestStepExecution/Views/FocusedResultView.swift
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/StageExecution/Coordinators/StageFocusCoordinator.swift
related_scenarios:
  - Record and confirm a result with required notes, measurement, or evidence
  - Navigate queue and review without losing the current selection or values
  - Correct results and retain immutable submitted history
---

# Implementation and PR plan - improvements 1 to 10

[[../Home|Vault home]] · [[../Plan.canvas|Vertical plan]] · [[../Phases/05-dynamic-interactions|Interaction acceptance details]]

## Scope and current state

The user approved implementing improvements **1-10** on 15 October 2026. Items **11-15 remain deferred** in milestone 11. Implementation is now available in three draft PRs; see [[Dynamic-implementation-delivery|the implementation and validation record]]. The detailed plan below retains the approved scope.

Shared feature branch: `simplified-ui-redesign`, published base `ceef990`. Planning started from `4f812a8`. The existing redesign is 12 local commits ahead of `develop`; a GitHub search found no PR for this head branch. Its last recorded validation is 138 tests / 141 cases passing and a successful Release build. Recheck the baseline at implementation kickoff rather than presenting the old run as new evidence.

Keep the queue's rounded appearance. Improve the task's visual size without showing additional information, stretching every element to fill a fixed percentage, or requiring a single screen layout to fit every content length and keyboard size.

## PR sequence

### Shared feature branch

The user selected `simplified-ui-redesign` as the shared feature branch. Do not open a foundation PR or target `develop`. All three implementation PRs target `simplified-ui-redesign` directly, start from this shared base, and include actual screenshot evidence in their descriptions. Do not merge them without user review.

### PR 1 - Larger, adaptive focused inputs

Proposed branch: `codex/ui-dynamic-inputs`.

Scope: **1, 2, 3, 4, 8, 9**. Milestone mapping: 11.8.1, 11.9.1, 11.9.2.

| Improvement | Change | Reference PDF pages |
| --- | --- | --- |
| 1 | Larger test/criteria/action text and touch targets with Dynamic Type. | 6-10 |
| 2 | A generous rounded work area that uses the middle/lower screen and adapts to keyboard/content height. | 6-7 |
| 3 | Pass/Fail transforms in place into an editable result and Save & next test. | 6-7 |
| 4 | Add note expands into an editor and contracts into a tappable preview; Fail opens required notes automatically. | 8, 15 |
| 8 | Prominent measurement value and unit; tap to edit and immediate format/range feedback. | 10-11 |
| 9 | Capture action becomes a real photo thumbnail with View/Retake. | 12-13, 34-35 |

Commit boundaries:

1. Rounded execution work area and typography; remove the old compact focus layout in the same commit. Capture normal, long-content, compact-width, and larger-text states.
2. Transforming outcome and note components; remove the rectangular note field, separate full-width Done presentation, and tiny edit-only targets they replace. Retain an explicit accessible keyboard completion action.
3. Large measurement component; remove the small inline measurement field it replaces.
4. Evidence preview component; replace the text-only evidence presentation. Keep the previous photo until a replacement is successfully stored. Retake cancellation or failure must not discard valid evidence or allow an invalid result through.

Behavior checks before implementation: required failure reason, optional note open/close without loss, note/measurement field identity, readiness after editing, invalid format/range feedback, and successful versus cancelled/failed photo replacement. Measurement never silently chooses the judge's outcome.

### PR 2 - Queue and review continuity

Proposed branch: `codex/ui-navigation-continuity`.

Scope: **5, 6, 10**. Milestone mapping: 11.8.2, 11.9.3.

| Improvement | Change | Reference PDF pages |
| --- | --- | --- |
| 5 | Queue opens at the current test, identifies it clearly, and preserves the judge's expansion choices. | 22-24 |
| 6 | Corrections return to the previous review position and identify the changed result. | 25, 27-30 |
| 10 | Larger review result/status labels and whole-card correction targets. | 25 |

Commit boundaries:

1. Coordinator-owned queue presentation state and current-test reveal; replace view-local expansion state that is lost when the drawer is recreated. Preserve the rounded queue styling.
2. Review return-position state and changed-result identification; replace the correction return path that recreates review at its start.
3. Whole-card review interaction; remove the predecessor pencil-only correction target without nesting conflicting buttons. Photo preview remains a separately accessible action.

Restore the visible result/anchor, not merely the active selection. Handle collapsed sections, changed validation content, multi-step cases, multiple corrections, missing/deleted anchors, and navigation to another stage. Resolve and reconfirm a flag before removing its attention item. Back to test retains the original case/step/value return point.

Behavior checks before implementation: queue expansion restoration, active-test reveal, review anchor restoration, stale-return rejection, independent stage contexts, flag correction, and accessible card/photo actions.

### PR 3 - Saved feedback and next-test transitions

Proposed branch: `codex/ui-next-test-transitions`.

Scope: **7**. Milestone mapping: 11.8.3.

- Coordinate the saved indication, progress change, and replacement of the focused test in the same work area. Reference PDF pages **17-19**.
- Replace the abrupt whole-test swap while retaining persistence gating and the brief existing success feedback. Do not add extra delay solely to display animation.
- Transition to the next required step/test in official order; the final test opens review and corrections return to review.
- Respect Reduce Motion and preserve VoiceOver context, result text/icons, and stable accessibility identifiers.
- Save failure, cancellation, navigation away, and repeated taps cannot advance or confirm a different result.

Commit boundary: one coordinated transition component replacing the abrupt switch, together with routing/persistence regressions and stable before/after captures. Capture motion separately when possible; static screenshots do not prove animation quality.

## Branch and review policy

Implement PR 1, then PR 2, then PR 3 on separate branches from `simplified-ui-redesign`. Every PR targets that shared feature branch. Keep diffs independent; validate the combined result in a temporary integration branch and resolve any overlap before delivery. Do not merge PRs as part of implementation.

Each implementation PR starts as a draft with Summary, Scope, Notes, and Validation. Each task commit adds its replacement component, removes its predecessor, and includes its snapshot checkpoint. Record actual PR URLs and source commits in the vault when created. No invented PR numbers or links.

## Execution and validation plan

1. Verify branch state and baseline; retain one dedicated FSAE simulator and DerivedData. Prefer XcodeBuildMCP when available; use the established direct Xcode workflow as a documented fallback.
2. Define behavior tests before changing state ownership or readiness. Keep field-entry state local to the focused form, navigation and return positions in the coordinator, and existing persistence/evidence ownership in services.
3. Build each component, install/launch the tested product after simulator readiness, and capture its accepted states. Visually inspect each capture for clipping, hierarchy, control size, and wrong-app/boot screens.
4. Use distinct sentinel values, such as note `Right restraint mount loose` and measurement `4.25 s`, to verify edits, navigation, and disk restore do not cross fields or tests.
5. Check compact widths, large text, keyboard-open states, long criteria, multiline labels, Reduce Motion, VoiceOver, save failure, and real evidence replacement. Record which checks actually ran; physical camera/touch behavior needs a device when available.
6. Run relevant checks for each PR and the full scheme plus Release configuration on the integrated result. Do not repeat broad checks without a new change or unresolved failure.
7. Update the milestone checkboxes only when the corresponding behavior and evidence are complete. Deliver an updated snapshot PDF that distinguishes this new pass from the original baseline, and update the vertical Canvas.

## Deferred

Improvements **11-15** remain documented: contextual + actions, Undo after advancement, haptics, expandable instructions, and press feedback. Preserve disabled session switching and deferred concurrency work. Do not mark broad evidence task 11.4 complete: Files import and media policy are beyond this photo-interaction scope.

## Definition of done

All ten approved improvements work together, predecessor controls are removed, field values remain durable through navigation and failure, each component has evidence, the full checks pass, and the updated report/vault reference actual source commits and PRs. The three draft PRs are implemented and independently target the shared feature branch; GitHub merges await human review.
