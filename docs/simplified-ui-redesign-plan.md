---
title: Inspection UI behavior
domain: inspection-event
feature: simplified-ui-redesign
status: active
owners: [Documenter, Developer]
source_files:
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/StageExecution/Views/FullStageView.swift
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/StageExecution/Coordinators/StageFocusCoordinator.swift
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/TestStepExecution/Views/FocusedResultForm.swift
related_scenarios: [Record and confirm inspection results, Return to stage queue, Correct results without losing drafts]
---

# Inspection UI behavior

This document describes the implemented inspection UI. Keep it aligned with the [system map](system-map.md); track defects in [known issues](known-issues.md) and unfinished scope in the [OpenSpec backlog](../openspec/changes/technical-inspection-event-development-plan/tasks.md).

## Judge workflow

1. Select or resume a team in Sessions. Add Team opens a sheet with separate display-name and car-number fields; its close icon has the accessible Cancel label.
2. Open a stage from Team. The queue shows confirmed progress, flags, independently expandable sections and the current test. Continue inspection restores an unfinished selection or finds the first unfinished result; a completed stage offers review.
3. Focus presents the vehicle, test, essential criteria and applicable safety warnings. Full instructions and rules are available from the top-right info toolbar. Multi-step cases expose a step selector.
4. Enter the schema-required result: outcome, measurement, notes and/or local photo evidence. Fail requires notes. Optional notes/photos, N/A, rerun, flags and early review are available through +.
5. Save & next waits for valid input and acknowledged persistence, briefly confirms saving, then advances. Failed saving retains input and exposes retry. Autosaved drafts do not count as explicitly confirmed results; editing invalidates confirmation.
6. Review results, correct individual steps, resolve flags and reconfirm. Corrections return to the existing review destination. Native Back uses the same route history and restores the original test selection when leaving early review.
7. Submit only when results are confirmed and valid, required evidence is locally available, flags are resolved and drafts are saved. Submission freezes an immutable snapshot and retains editable drafts.

## Presentation and accessibility

- Shared action buttons use native regular glass, 18% tint, 24-point rounded corners and large controls. Pass/Fail retain semantic colors and text/icon cues.
- Required criteria and applicable safety warnings remain visible. Unanswered results begin neutral; successful routine autosaving stays quiet.
- Notes expand into an editor and contract into an editable preview. Measurements retain units and range feedback. Evidence provides preview and retake; cancellation/import failure preserves the previous evidence until replacement succeeds.
- Queue section choices and review scroll position belong to stage presentation state. Corrected results are temporarily identified.
- Confirmed advancement respects Reduce Motion. Animation never decides whether a save succeeded or a result can advance.
- Internal Settings gates DEBUG actions, Debug display and the step-type badge. The badge is absent from Release.
- Tab visibility follows persistent stage navigation state: hidden in focus and restored on return to overview/review.

These are implemented behavior and acceptance requirements, not certification that every native interaction is validated. See [validation](validation.md) and the [notes/outcome editing issue](known-issues.md#outcome-editing-after-notes).

## Deferred scope

Contextual + labels, undo after advancement, haptics, expandable inline criteria and additional press feedback remain deferred (improvements 11–15). Team switching is disabled. Reset/session history, rechecks, sticker eligibility, stopwatch timing, broader file import/media policy and concurrency cleanup remain backlog work. Do not enable or integrate these implicitly during UI maintenance.
