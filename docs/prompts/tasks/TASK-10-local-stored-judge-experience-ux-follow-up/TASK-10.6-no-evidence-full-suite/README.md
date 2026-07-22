# TASK#10.6 SPDD Prompt Run

Task: `10.6 Allow a judge to run the full inspection test suite without attaching evidence. Evidence-required controls remain visible as deferred/metadata-only status, but evidence attachments do not block completion in this working version.`

Purpose: allow the lean local inspection suite to complete before real media capture/storage exists.

Branch: `codex/task-10-6-no-evidence-full-suite`

Expected PR title: `TASK#10.6: No-Evidence Full Suite`

Run prompts in this order:

1. Requirements: read common instructions, validation specs, `.feature` evidence and submission scenarios, and current validation/stage submission files.
2. Entities: identify validation policy, evidence status view state, stage blockers, submission snapshot inputs, and accessibility copy.
3. Approach: add failing tests showing missing outcomes/failed notes still block while missing evidence no longer blocks in Task 10 mode.
4. Structure: keep evidence controls visible in views and implement the non-blocking policy in validation/service or coordinator state, not ad hoc view checks.
5. Operations: implement, validate, update OpenSpec checkbox, commit, push, and open a draft PR automatically.
6. Norms: preserve non-color evidence status cues and VoiceOver labels for deferred evidence.
7. Safeguards: do not add camera/gallery/Files import, media storage, recheck service, or sticker eligibility.

Agent/skill/tool mapping: use `../common-instructions.md`.

Validation:

- A full stage/suite can complete without evidence attachments.
- Missing required outcomes and required failed notes still block submission.
- Evidence-required controls remain visible as deferred or metadata-only.
- Manual validation maps to evidence scenarios with the Task 10 exception documented in PR notes.
