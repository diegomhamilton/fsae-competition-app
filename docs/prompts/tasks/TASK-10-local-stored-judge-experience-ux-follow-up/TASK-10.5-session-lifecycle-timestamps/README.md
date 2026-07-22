# TASK#10.5 SPDD Prompt Run

Task: `10.5 Add local session lifecycle for one team: start session, record startedAt, end/complete session, record endedAt, persist active session state, and restore the active session after relaunch.`

Purpose: make a locally created team session durable across launch cycles and visibly timestamped.

Branch: `codex/task-10-5-session-lifecycle-timestamps`

Expected PR title: `TASK#10.5: Session Lifecycle Timestamps`

Run prompts in this order:

1. Requirements: read common instructions, OpenSpec tasks/design, `.feature` session start/resume scenarios, and current session persistence files.
2. Entities: identify `InspectionSession`, active session context, timestamp storage, store APIs, coordinator intents, and session selector display state.
3. Approach: add failing tests for `startedAt`, `endedAt`, persisted active session, and relaunch restore before implementation.
4. Structure: keep timestamp persistence in the store/service boundary and UI display in session/team views through structured strings.
5. Operations: implement, validate, update OpenSpec checkbox, commit, push, and open a draft PR automatically.
6. Norms: use actor-isolated storage for mutable session state and main-actor coordinators for UI state.
7. Safeguards: do not implement reset/history from TASK#10.7 and do not change evidence policy from TASK#10.6.

Agent/skill/tool mapping: use `../common-instructions.md`.

Validation:

- Starting a team session records `startedAt`.
- Completing or ending a session records `endedAt`.
- Relaunch restores the active session for the selected team.
- Manual validation maps to `Start a new inspection session for a team` and `Resume an in-progress inspection session`.
