# TASK#8 Operations Summary Prompt

Use this operation-first SPDD prompt for the dedicated UI test and snapshot PR.

| Task | PR Operation Summary | Likely Files | Validation | Split Trigger |
| --- | --- | --- | --- | --- |
| 8.1 | Open the dedicated UI-test PR only after accessibility identifiers, navigation hooks, and store-backed draft save/restore through coordinators/views exist. | PR description, prompt docs | Confirm prerequisites from TASK#6 and TASK#7. | Split if prerequisites are incomplete and need implementation fixes. |
| 8.2 | Add dedicated UI automation launch fixtures for positive, negative, and edge states using mock data. | UI test launch config, mock fixture loader, test helpers | Launch app into each fixture state. | Split if fixture plumbing touches app runtime code and project config together. |
| 8.3 | Add dedicated UI automation coverage for login, session selector, stage navigation, test case navigation, step editing, validation blocking, team switching, recheck review, and sticker eligibility. | UI automation test files | UI automation run on selected simulator. | Split by flow family if file count exceeds 10 or failures are hard to isolate. |
| 8.4 | Assert required controls and statuses by stable accessibility identifiers rather than localized labels. | UI automation assertions, accessibility ID helpers | Tests fail if identifiers are missing or unstable. | Split if app code needs identifier fixes. |
| 8.5 | Add Swift Testing-compatible snapshot tests for practical high-value states: test step, test case, stage list, validation blocked, recheck required, and sticker eligible. | Snapshot test target/config/baselines | Swift Testing snapshot command with controlled simulator/runtime. | Split if snapshot dependency or baselines create large diffs. |
| 8.6 | Document UI test coverage back to feature scenarios and personas. | Documentation, PR validation notes | Scenario/persona mapping review. | Keep docs separate if test PR is already large. |

Common PR summary language:

```md
## Summary

Adds dedicated UI-test or snapshot coverage for the inspection event flow using stable navigation hooks and accessibility identifiers.

## Scope

- <Launch fixture or UI flow covered>
- <Stable identifiers asserted>
- <Feature scenarios and personas mapped>

## Notes

- UI tests are isolated from implementation PRs.
- TASK#7 coordinator/view draft persistence must be wired before restore-flow UI tests rely on it.
- Localized labels are not used as primary selectors.
- Snapshot coverage is limited to high-value, stable states.

## Validation

- `<xcodebuild test command or not-run reason>`
- <Simulator/runtime used>
```
