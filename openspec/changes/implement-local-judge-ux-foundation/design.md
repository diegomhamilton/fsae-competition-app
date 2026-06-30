# Design

## Scope

Implement Task 10.1 through Task 10.7 after the design review approves the interaction decisions.

In scope:

- Session and active dashboard context polish.
- Stage/test case/step copy and layout cleanup.
- Actionable validation blocker selection.
- Pending versus incomplete semantics.
- Notes and evidence label vocabulary.
- Immediate draft persistence for validation corrections.

Out of scope:

- Camera/photo capture.
- Full media storage policy.
- Recheck service implementation.
- Sticker eligibility calculation.
- Egress stopwatch timing.
- Dedicated UI automation PR.

## Interaction Model

Each judge-facing screen should answer:

- Which event is active?
- Which team/session is active?
- Which stage/test case/step is being edited?
- Is the draft saved, blocked, incomplete, or ready?
- What is the next useful judge action?

Validation summaries should expose selectable blockers. Selecting a blocker should route or focus the corresponding control. Corrections must flow through the existing draft and persistence boundaries so relaunch restore remains trustworthy.

## State Semantics

Do not present `Pending` as a judge decision when Pass, Fail, and N/A are the actual choices. Required-but-unanswered steps should be derived incomplete state. If the underlying model still has a pending enum case for compatibility, the UI should label it as incomplete until a judge selects a real outcome.

## Verification

Use focused tests for:

- View-state text and next-action decisions.
- Validation blocker routing/focus data.
- Draft persistence after corrections.
- Notes/evidence label state.
- Pending/incomplete state derivation.

Manual validation should cover relaunch restore UX, blocked submit recovery, keyboard dismissal, VoiceOver operation, and common judge recovery paths.

