---
title: Judge navigation requirements
domain: inspection-event
status: active
owners: [Architect, Documenter]
source_files: [docs/system-map.md, docs/simplified-ui-redesign-plan.md]
related_scenarios: [Start or resume inspection, Correct results without losing drafts]
---

# Judge navigation requirements

The [system map](../../../docs/system-map.md) owns the current routing description and [inspection UI](../../../docs/simplified-ui-redesign-plan.md) owns judge-facing behavior. Update those documents with implementation changes instead of maintaining a separate tab/route proposal.

- Sessions selects or resumes a team; Add Team is a dismissible sheet.
- Team opens stage queue, focused test and review destinations within its navigation stack.
- Native Back and interactive pop must retain draft values and correct review/test return targets.
- Confirmation advances only after acknowledged persistence; correction returns to review.
- Session switching is disabled; reset/history, rechecks and stickers are deferred in the [active backlog](../../../openspec/changes/technical-inspection-event-development-plan/tasks.md).

Use the [validation checklist](../../../docs/validation.md#required-manual-checks) for unresolved native interaction and accessibility checks. Requirements do not imply those checks have passed.
