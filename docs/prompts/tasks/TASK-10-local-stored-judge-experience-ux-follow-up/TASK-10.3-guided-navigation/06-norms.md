# Norms Prompt

Apply the project norms to this task:

Task: `10.3 Refactor judge navigation so Sessions, Team, and Stage are the top-level landmarks, remove the standalone Case tab, and make Stage contain the case UI with dominant next-action and focused one-step editing.`

Check the proposed work against these norms:

- Start after TASK#7 establishes stored local session behavior.
- Keep the judge task flow primary: restore context, inspect, correct blockers, submit, recheck, and verify sticker state.
- Replace prototype copy with persisted event, team, stage, and test case context.
- Make validation blockers actionable and persist corrections immediately.
- Use Swift Testing for logic, state, and helper checks.
- Use manual validation for Dynamic Type, VoiceOver, relaunch restore, and recovery paths.
- Split strongly if media capture, stopwatch timing, persistence, and layout work appear in one PR.
- Use Swift Testing for unit and integration checks.
- Keep dedicated UI automation in the TASK#8 PR.
- Use stable accessibility identifiers instead of localized labels for UI automation.
- Keep PR titles in the `TASK#10.3: <summary>` format.
- Keep commit titles 52 characters or fewer.
- Keep manual validation honest: `not run` is better than unsupported claims.

Return any adjustments needed before implementation.

Additional TASK#10.3 norm:

- By the end of TASK#10.3, the app should have no standalone `Case` tab; case-level UI lives inside Stage, while Step Detail remains a guided drill-in from Stage/case/blocker flows.

Expected PR title:

`TASK#10.3: Guided Navigation`
