---
title: Known inspection issues
domain: inspection-event
status: active
owners: [Developer, Tester]
source_files:
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/TestStepExecution/Views/FocusedResultInputView.swift
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Features/TestStepExecution/Views/FocusedResultView.swift
related_scenarios: [Edit a recorded result, Create a team]
---

# Known issues

Remove resolved entries after the fix and meaningful regression coverage land. Keep exact source and reproduction details current; do not retain closed-issue ledgers here.

## Outcome editing after notes

Priority: P2. Status: callback-level conflict reproduced; native touch confirmation pending.

On reviewed source `8a7705f`, choose Pass, add a valid optional note with the keyboard focused, then tap the compact outcome/pencil pill above the note. The pill calls `editResult(includingEvidence: false)` and clears focus (`FocusedResultInputView.swift:18–20`). The notes-to-nil focus callback calls `finishInput()` (`FocusedResultView.swift:217–219`), clearing `isEditingOutcome` (`FocusedResultForm.swift:135–141`). Valid input returns to the summary instead of offering Pass/Fail choices; another edit action is needed. Fail with a valid required note follows the same state path.

An isolated callback replay fails the expectation that outcome-edit mode survives. This demonstrates the state conflict, not SwiftUI focus timing on a device. Fix by preserving the requested edit intent across programmatic focus dismissal, and verify both outcome changes and Done behavior without losing notes. App behavior has not been changed by the documentation review.

## Add Team first-focus stall with debugger attached

Status: reported trigger narrowed; internal cause unresolved.

The user observed the first-focus stall with Xcode attached, then stopped Xcode and launched the same installed app from Home Screen, where focus was responsive. This observation does not establish the internal cause. The failed runtime workaround from PR #104 must not be revived on that basis. The optional no-debugger scheme from closed, unmerged PR #106 is outside the feature implementation.

Any further device comparison must use the same installed app and record debugger/launch context. Coordinate before a physical-device installation.

## Actor-isolation warnings

The current test configuration emits actor-isolation diagnostics in app/store, Codable models and validation helpers. A passing test action is not a warning-free strict Swift 6 certification. Resolve in the deferred concurrency work, preserving UI and persistence scope.
