# Inspection issues and redesign follow-up

Originally reviewed: 2026-07-05
GitHub status refreshed: 2026-10-12 (America/Recife)
Repository: diegomhamilton/fsae-competition-app

## Current GitHub state

The repository-wide open-issue search returned one issue, #72. Individual reads confirmed the states below. This document updates local planning only; no GitHub issue was modified.

| Issue | Current state | Relevance |
| --- | --- | --- |
| [#55 State Complete is shown but Fail or Pending is selected](https://github.com/diegomhamilton/fsae-competition-app/issues/55) | Closed as completed on 2026-07-05 | Historical result/draft synchronization defect; preserve regression coverage. |
| [#56 Stage shows Completed while unanswered](https://github.com/diegomhamilton/fsae-competition-app/issues/56) | Closed as completed on 2026-07-05 | Historical dashboard completion defect; use team/session draft state rather than static content progress. |
| [#64 Switching stages empties another stage's progress](https://github.com/diegomhamilton/fsae-competition-app/issues/64) | Closed as completed on 2026-07-18, local time | The issue comment identifies [PR #68](https://github.com/diegomhamilton/fsae-competition-app/pull/68) as its fix. The local code contains stage-scoped draft state and all-stage restoration; do not undo these while redesigning. |
| [#72 Groups of test cases should expand/collapse](https://github.com/diegomhamilton/fsae-competition-app/issues/72) | Open | Relevant to grouped queue navigation and final review. |

Closed issue status is not proof that every current branch is regression-free. Redesign validation is recorded in the [implementation vault](simplified-ui-vault/Phases/04-final-checks-and-pdf.md).

## Active issue: #72

The issue requests expandable/collapsible groups such as Spare parts and Changing Procedure. The redesigned queue has independent expandable section controls; review presents grouped results for final checking. Queue snapshots verify expansion and collapse with isolated fixtures. This does not establish that the specific groups in the issue are mapped correctly in every bundled stage.

Before treating #72 as resolved:

1. Confirm those named groups are represented as separate sections in the bundled content.
2. Verify each group's test cases expand and collapse independently.
3. Verify expansion does not change result values or selected test context.
4. Verify the controls work with VoiceOver and large text.

Keep this behavior on the queue and review surfaces. The execution surface should show the active test rather than the full grouped overview. Leave the GitHub issue open until its actual scenario is verified.

## Agreed redesign principles retained from the original proposals

The original document described #55 and #56 as open and inferred possible causes from the July code. Those findings are historical, not the latest repository state. The useful cross-cutting recommendations remain:

- Derive result, progress, and validation from the same team/session/stage-scoped draft state.
- Distinguish unanswered, missing required data, recorded failure, and recorded pass/N/A.
- A failed outcome with its required note can be valid for recording without meaning the vehicle passed inspection.
- Use a shared derivation of these states for test cards, queues, review, and dashboard progress so their labels do not disagree.
- Avoid using Complete as a substitute for Passed. Keep result and completeness semantics distinct.
- Preserve draft isolation when navigating between stages and vehicles.

For focused execution, an unanswered test is neutral. Show a specific missing-field message only when it is actionable; avoid simultaneously showing a red border, Blocked badge, and generic missing-outcome message before the judge acts.

## Result component implemented after human review

Pass, Fail, and Save & next belong to one changing component, rather than three competing actions. The user's requested progression is result input, ready to save, then saving/confirmation and automatic next-test navigation. A neighboring + menu exposes optional notes/evidence and existing exceptional actions.

Input controls follow the step's actual requirements: pass/fail, measurement with unit, or photo/evidence as appropriate. Required notes and other required fields must be satisfied before Save & next is offered. Values remain editable, and failed saving never advances the test.

The user authorized implementation on 2026-10-12. Components are implemented with confirmed-result status, recoverable persistence, real photo evidence, and reversible review navigation. See [the implementation checkpoints](simplified-ui-redesign-plan.md).

## Scope exclusions

Concurrency fixes are retained as deferred planning and preserved branch history; they are not integrated into simplified UI work. Session switching/reset/history was disabled by the user because it was not working properly, and it is not a focus of this redesign. Deleting the old persistence worktree does not authorize undoing persistence behavior in the active branch.
