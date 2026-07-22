# TASK#10 Common Instructions

Use these instructions across every TASK#10 operation prompt.

- Start after TASK#7 establishes stored local session behavior by wiring coordinators/views to store-backed draft save/restore.
- Keep judge task flow primary: create a team, start a session, record start/end timestamps, run the full inspection suite without evidence attachments, reset active progress if necessary, and review past executions.
- Replace prototype copy with event, team, stage, and test case context that survives relaunch.
- Do not seed user-facing mock teams in the production launch path. Mock teams may remain in tests, previews, and explicit debug fixtures.
- Evidence attachments are out of scope for Task 10. Evidence-required statuses may remain visible, but camera, gallery/photo-library, Files import, attachment creation, and media storage must not block completing the suite.
- Keep broad UX polish, actionable validation focus, Pending semantics, recheck service, sticker eligibility, stopwatch timing, UI automation, snapshots, and EV enhancements in Parking Lot 12.
- Use one OpenSpec task as one branch and one PR. Do not combine multiple active Task 10 tasks into one PR.
- Record estimated and actual input/output/total tokens plus estimated and actual time in `task-10-full-suite-session-plan.xlsx` for every remaining Task 10 PR.
- Treat user-entered form data as identity-sensitive. Use typed command/value models for multi-field submissions, test with deliberately distinct values, and validate persisted/displayed results field by field.

## Required Agent, Skill, and Tool Mapping

Use this mapping for TASK#10.4 through TASK#10.8.

| Workflow need | Agent owner | Required skills | Tools |
| --- | --- | --- | --- |
| Slice planning, branch naming, PR scope, and task checkbox updates | Planner | `.skills/personas.md`, `.skills/architecture-developer.md` when boundaries change | `git status`, `git diff`, `git switch -c`, OpenSpec task file edits |
| Domain, service, coordinator, persistence, and SwiftUI implementation | Developer | `.skills/architecture-developer.md`, `.skills/concurrency-developer.md`, `.skills/swiftui-developer.md`, `.skills/accessibility.md` when UI changes | `rg`, `xcodebuild`, `apply_patch`, `git add`, `git commit`, `git push` |
| Tests, manual validation, accessibility coverage, and feature scenario mapping | Tester | `.skills/personas.md`, `.skills/accessibility.md`, plus architecture/concurrency skills for async behavior | `xcodebuild test`, targeted Swift Testing files, manual simulator/build notes |
| PR notes, validation evidence, and tracking workbook entries | Documenter | `.skills/personas.md`, `.skills/accessibility.md` when documenting judge/student impact | GitHub connector PR creation, `task-10-full-suite-session-plan.xlsx` update |

Identity-sensitive form safeguard:

- Developer must pass multi-field user input through typed immutable payloads before async work begins.
- Tester must include at least one value-trace test or manual check using different values for every field, then confirm the values persist and render in the intended locations.
- Planner must put that value trace in the PR `Validation` checklist when a task moves form input into a store, snapshot, history entry, or API boundary.

Publishing rules:

- Create one branch and one draft PR per OpenSpec task.
- Push with `GIT_SSH_COMMAND='ssh -o BatchMode=yes' git push -u origin <branch>` so the workflow does not wait for interactive SSH prompts.
- Open the draft PR through the GitHub connector after the branch is pushed.
- Do not ask for human confirmation unless the worktree contains unrelated tracked changes or a command requires a new system permission approval.
- If `gh` or `openspec` is unavailable, use local git plus the GitHub connector and update `openspec/changes/technical-inspection-event-development-plan/tasks.md` directly.
