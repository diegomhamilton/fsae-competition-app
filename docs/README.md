---
title: Active documentation
domain: inspection-event
status: active
owners: [Documenter]
source_files: [docs/system-map.md, docs/simplified-ui-redesign-plan.md]
related_scenarios: [Conduct a local inspection, Maintain inspection documentation]
---

# Active documentation

This index describes the maintained documentation for the current feature implementation. Read the system map for actual behavior and OpenSpec tasks for unfinished work. Documentation must change with implementation; completed prompts, delivery journals, old screenshots and reports do not belong in this tree.

| Document | Purpose | Update when |
| --- | --- | --- |
| [System map](system-map.md) | Actual routing, state ownership, persistence and service wiring | Navigation, ownership or storage changes |
| [Inspection UI](simplified-ui-redesign-plan.md) | Current queue/focus/review behavior and interaction requirements | A judge-facing interaction changes |
| [Known issues](known-issues.md) | Reproducible unresolved defects and investigation limits | An issue is reproduced, fixed or disproved |
| [Validation](validation.md) | Current source-qualified result and remaining checks; repeatable simulator workflow | Source or validation coverage changes |
| [Maintenance](maintenance.md) | Documentation policy, ownership and cleanup conditions | Workflow or documentation responsibilities change |
| [Technical overview](inspection-event/README.md) | Architecture, rechecks, accessibility and localization conventions | Feature boundaries or conventions change |
| [Source organization](inspection-event/organization-plan.md) | Current folders and file-placement rules | Source layout changes |
| [Extension tutorials](inspection-event/tutorials.md) | Add content, validation, identifiers and persona scenarios | An extension point changes |
| [Planning and review hygiene](inspection-event/review-hygiene.md) | Reusable planning prompts, branch, commit and PR requirements | Planning/review workflow changes |
| [OpenSpec backlog](../openspec/changes/technical-inspection-event-development-plan/tasks.md) | Unfinished requirements and acceptance gates | Scope changes or completion is verified |

Repository guidance remains in [CLAUDE.md](../CLAUDE.md), role responsibilities in `.agents/`, and domain guidance in `.skills/`. OpenSpec proposals/design/specs define requirements, including explicitly deferred capabilities; they are not proof of implementation. The [behavioral scenarios](../Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature) remain the acceptance backbone.
