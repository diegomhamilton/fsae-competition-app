# TASK#10 Operations Summary Prompt

Use this operation-first SPDD prompt for the lean Task 10 local full-suite session version.

Task 10 is intentionally small: user-created team, local session start/end timestamps, full inspection suite execution without evidence attachments, reset, and past execution history. Move broad polish, media evidence input, recheck, sticker eligibility, stopwatch, UI automation, snapshots, and EV enhancements to Parking Lot 12.

Token and time tracking:

- Use `task-10-full-suite-session-plan.xlsx` as the planning and actuals tracker.
- Fill actual token and time fields at the end of every task PR.
- One task row equals one PR. Do not combine multiple task rows in one PR.

| Task | PR Operation Summary | Likely Files | Validation | Split Trigger |
| --- | --- | --- | --- | --- |
| 10.1 | Complete: audit session selector, dashboard, full stage, test case, step overview, and team switch views for minimum UX polish after TASK#7 links coordinators/views to store-backed draft save/restore. | Audit doc, view notes, issue checklist | Manual audit mapped to judge flow. | Keep audit separate if it finds broad UI changes. |
| 10.2 | Complete: replace prototype headers/backgrounds and mock copy with persisted event/team/stage/test case context. | SwiftUI views, Strings enums, tests/previews | Relaunch restore shows clear active local session. | Split if visual treatment and state plumbing both change heavily. |
| 10.3 | Complete: guided navigation refactor from `Design/Flows/InspectionEvents/JUDGE_NAVIGATION_FLOW_PROPOSAL.md`. | `ContentTabsView`, `ProposedScreen`, app/session coordinators, `FullStageView`, `TestCaseView`, view state/tests | Completed in `codex/milestone-10-design-review`. | None. |
| 10.4 | Next: add a local team catalog and no-default-mock production launch. | `InspectionEventStore`, app factory, session selector state, tests | User can create a team; production launch starts with no seeded mock teams; mock teams remain test/preview/debug only. | Split only if team persistence needs a separate storage contract. |
| 10.5 | Add session lifecycle timestamps and relaunch restore. | Session record model/store/coordinator, persistence tests | Starting a session records `startedAt`; completing/ending records `endedAt`; relaunch restores active session. | Split only if timestamp migration creates independent storage risk. |
| 10.6 | Allow full inspection suite execution without evidence attachments. | Validation service, evidence status UI, test case/stage flow tests | Full suite can complete without camera/gallery/file attachments; evidence status is visible as deferred/non-blocking. | Split only if evidence policy conflicts with existing validation schema. |
| 10.7 | Add reset and past execution history. | Session hub, reset confirmation, session history view/state, tests/docs | Reset clears active progress safely; completed executions remain visible with start/end timestamps. | Split only if reset cleanup and history display become separate rollback boundaries. |
| 10.8 | Track actual token and time usage for Task 10 PRs. | `task-10-full-suite-session-plan.xlsx`, PR notes | Actual input/output/total tokens and actual time recorded for 10.4 through 10.7. | None; this is a tracking PR/task. |

Common PR summary language:

```md
## Summary

Delivers the smallest working local full-suite session flow without evidence attachments.

## Scope

- <Views, models, coordinators, persistence, or tests changed>
- <Judge recovery path or UX state covered>
- <Feature scenarios and accessibility states mapped>

## Notes

- One OpenSpec task maps to one PR.
- Evidence attachment input is out of scope for Task 10.
- Session history must include start and end timestamps.
- Reset must not delete past completed executions.
- Actual token and time usage must be recorded in `task-10-full-suite-session-plan.xlsx`.

## Validation

- `<test command>`
- <Manual checks for Dynamic Type, VoiceOver, relaunch restore, and recovery paths>
```
