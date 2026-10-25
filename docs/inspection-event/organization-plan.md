---
title: Source organization
domain: inspection-event
status: active
owners: [Architect, Developer]
source_files: [FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist]
related_scenarios: [Maintain inspection feature boundaries]
---

# Source organization

Application source lives under `FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/`; tests live in the adjacent `FSAEInspectionChecklistTests/` target.

| Folder | Responsibility |
| --- | --- |
| `App/` | Entry point, root tabs, bindings and Internal Settings |
| `Common/UI/` | Shared visual controls and keyboard infrastructure |
| `Features/InspectionContent/` | Content models and bundled JSON loading |
| `Features/SessionFlow/` | App/event/execution coordinators, team/session models, store and selection/dashboard views |
| `Features/StageExecution/` | Queue/focus/review coordination, stage presentation and submission controls |
| `Features/TestCaseExecution/` | Case/draft models, validation projections and shared helpers |
| `Features/TestStepExecution/` | Focused result forms, measurement/notes/photo views and evidence service |
| `Features/Validation/` | Validation policies and messages |
| `Features/Persistence/` | JSON schemas and actor-isolated local file persistence |
| `Features/Submission/` | Immutable submission snapshot service |
| `TestSupport/` | Fixtures and isolated DEBUG snapshot/replay harness |
| `InspectionEvent/` | Bundled official inspection JSON |

Place content and draft values in models, workflow/selection in coordinators, async storage/validation in services and rendering/local input state in views. Follow [the system map](../system-map.md) for actual ownership and [tutorials](tutorials.md) for extension steps. Do not reintroduce removed carousel screens or create empty feature folders for deferred requirements.

Source moves must preserve symbols, persistence contracts and routing. Run the smallest relevant checks for the affected boundary and update these paths in the same PR.
