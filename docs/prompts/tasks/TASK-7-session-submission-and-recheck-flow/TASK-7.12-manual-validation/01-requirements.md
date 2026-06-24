# Requirements Prompt

You are helping with SPDD for this task:

Task: `7.12 Manually validate start, resume after app relaunch, submit, blocked submit, team switch, recheck, sticker eligibility, per-test-case JSON files, and team submission folders against the .feature file.`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible or reviewer-visible outcome
- Acceptance source, especially `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature` when relevant
- Required behavior
- Out of scope behavior
- Completion signal
- PR review risk if this task grows too broad

Keep this focused on what must be true, not how to build it.

Context:

- Macro-task: TASK#7 Session, Submission, and Recheck Flow
- Subtask: TASK#7.12
- Expected PR title: `TASK#7.12: Manual Validation`
- Feature branch: `codex/inspection-event-session-flow`
- Suggested task branch: `codex/inspection-event-session-flow-7-12-manual-validation`
- Operation summary: Prepare and run manual validation for the full local session, submission, recheck, sticker, and JSON-folder workflow.
- Likely files or targets: Manual checklist; PR validation note; feature scenario map
- Validation: User-run app evidence only; static review can prepare checklist.
- Split trigger: Keep as documentation/validation PR if implementation evidence is not available.
- Common instructions:
- Start from OpenSpec design and the inspection_event_use_cases.feature file.
- Keep Application Support JSON storage scoped by event, team, session, stage, and test case ID.
- Use Swift Testing for unit and integration checks.
- Use actor isolation for persistence, event-store, and mutable local state boundaries.
- Keep submitted snapshots immutable; corrections flow through rechecks.
- Use task-sized commits and split if the PR crosses more than 10 files or mixes unrelated review contexts.
- Do not claim manual validation unless actual app evidence is recorded.
