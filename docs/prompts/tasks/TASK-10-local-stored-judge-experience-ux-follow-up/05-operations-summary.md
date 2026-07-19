# TASK#10 Operations Summary Prompt

Use this operation-first SPDD prompt for local stored judge experience UX follow-up.

Tentpole 2 also owns the TASK#7 continuation items for rechecks, sticker eligibility, and full manual validation because those items close the judge-facing workflow after the session/submission foundation is available.

| Task | PR Operation Summary | Likely Files | Validation | Split Trigger |
| --- | --- | --- | --- | --- |
| 10.1 | Complete: audit session selector, dashboard, full stage, test case, step overview, and team switch views for minimum UX polish after TASK#7 links coordinators/views to store-backed draft save/restore. | Audit doc, view notes, issue checklist | Manual audit mapped to judge flow. | Keep audit separate if it finds broad UI changes. |
| 10.2 | Complete: replace prototype headers/backgrounds and mock copy with persisted event/team/stage/test case context. | SwiftUI views, Strings enums, tests/previews | Relaunch restore shows clear active local session. | Split if visual treatment and state plumbing both change heavily. |
| 10.3 | Next: implement the guided navigation refactor from `Design/Flows/InspectionEvents/JUDGE_NAVIGATION_FLOW_PROPOSAL.md`: keep `Sessions`, `Team`, and `Stage` as top-level landmarks, remove the standalone `Case` tab, and make Stage contain the case UI with dominant next-action and focused one-step editing. | `ContentTabsView`, `ProposedScreen`, app/session coordinators, `FullStageView`, `TestCaseView`, view state/tests | Swift Testing for route transitions plus manual one-step/multi-step, relaunch, empty-state, and VoiceOver checks. | Split if route model changes and Stage/Case UI composition cannot be reviewed together. |
| 10.4 | Refactor step metadata layout for compact widths and Dynamic Type: ID/title/status first, rule references secondary, compact open action. | `StepOverviewView`, related components | Dynamic Type and compact width checks. | Split if rule reference presentation becomes a reusable component. |
| 10.5 | Make validation blockers selectable to focus missing outcome, note, measurement, or evidence control, then persist correction immediately. | Validation UI, coordinator intents, persistence calls, tests | Focus routing tests and persisted JSON draft checks. | Split if focus routing and persistence updates exceed one review context. |
| 10.6 | Review `Pending` semantics so incomplete required steps are derived draft state rather than a judge decision. | Models, validation, UI labels, tests | Tests prove Pass/Fail/N/A are decisions and incomplete is derived. | Split if migration from stored pending values is needed. |
| 10.7 | Clarify notes/evidence states with labels like `Add Evidence`, `1 Evidence`, `Required Evidence Missing`, `Add Note`, and `Edit Note`, round-tripping through drafts. | Step/test case UI, Strings enums, draft persistence tests | Label state matrix and JSON round-trip tests. | Split if evidence state model changes independently. |
| 10.8 | Add camera/photo capture support for evidence-required steps, persisting captured file metadata while keeping full media storage behind policy. | Evidence metadata, capture adapter, tests, UI affordance | Metadata persistence tests and manual capture smoke note. | Split if platform permissions or media storage policy enters scope. |
| 10.9 | Implement `RecheckService` so failed test cases create open recheck items and accepted reviews close them. | Recheck service, recheck models, tests, recheck review surfaces as needed | Failed case creates open item; accepted review closes item; judge can understand and recover from recheck state. | Split if service behavior and UI review flow cannot be reviewed together. |
| 10.10 | Implement sticker eligibility calculation from submitted stages and open rechecks. | Eligibility service/model, tests, team/stage eligibility display as needed | Eligibility matrix tests for submitted/missing/open-recheck states; eligibility is clear in judge workflow. | Split if eligibility service and UI presentation create separate review contexts. |
| 10.11 | Manually validate start, resume after app relaunch, submit, blocked submit, team switch, recheck, sticker eligibility, per-test-case JSON files, and team submission folders against the `.feature` file. | Checklist, PR validation note, manual evidence | User-run app evidence only, mapped to Gherkin scenarios. | Keep as documentation/validation PR if implementation evidence is not available. |
| 10.12 | Add stopwatch timing for egress measurement with start, stop, reset, manual override, range validation, draft persistence, and accessible announcements. | Egress timing UI/model/service/tests | Timer tests, validation range tests, accessibility manual note. | Split if timer engine and UI integration both grow. |
| 10.13 | Add focused Swift Testing checks and manual validation for relaunch restore UX, validation focus, camera metadata, stopwatch timing, keyboard dismissal, VoiceOver, and recovery paths. | Tests, validation checklist, PR notes | Swift Testing plus manual validation evidence. | Keep as validation PR if implementation work is already large. |

Common PR summary language:

```md
## Summary

Polishes the stored local judge workflow so the active inspection context, next action, correction path, and persisted draft state are clear during real inspection use.

## Scope

- <Views, models, coordinators, persistence, or tests changed>
- <Judge recovery path or UX state covered>
- <Feature scenarios and accessibility states mapped>

## Notes

- Prototype copy is replaced with persisted inspection context.
- Stored context means coordinators/views are wired to the store, not only that a store type exists.
- Validation corrections persist immediately to the local draft JSON.
- Media capture remains metadata-first until storage policy is reviewed.

## Validation

- `<test command>`
- <Manual checks for Dynamic Type, VoiceOver, relaunch restore, and recovery paths>
```
