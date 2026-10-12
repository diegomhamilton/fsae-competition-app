# Result component checkpoint

Source checkpoint: the feature commit containing this note and the images.

Xcode 26.2, iPhone 17 Pro / iOS 26.2, dedicated simulator `07400928-689C-439C-A2A9-4734BFF9B89B`. Build passed. Every capture passed boot rejection and visual inspection.

- `01-input.png`: Neutral required outcome input; no initial error or disabled Save button.
- `02-ready.png`: Pass selected: summary/edit path and Save & next replace input controls.
- `03-required-notes.png`: Fail reveals the required reason field before confirmation.
- `04-fail-ready.png`: Failure reason retained beside the recorded outcome.
- `05-measurement-keyboard.png`: Required measurement, unit, decimal keyboard, and one visible Done action.
- `06-measurement-ready.png`: Valid measurement becomes a concise result summary.
- `07-photo-input.png`: Photo-only schema shows required photo input without artificial Pass/Fail.
- `08-photo-ready.png`: Actual persisted fixture image enables photo preview and confirmation.
- `09-plus-menu.png`: Native secondary menu combines notes, photos, N/A, rerun, flag, and review.
- `10-optional-notes.png`: Optional notes appear only after requested.
- `11-save-failure.png`: Failed write retains Pass and exposes retry without advancing.
- `12-saving.png`: Saving replaces the primary action and disables navigation.
- `13-confirmed.png`: Brief success confirmation; this DEBUG fixture holds the transient state.
- `14-next-test.png`: Actual confirmation callback opens DRIVER SUIT, 4 of 9.
- `15-flagged-result.png`: Outcome and unresolved review flag remain separate.
- `16-safety-warning.png`: Applicable safety warning stays visible in normal execution.

Replaces the old carousel/card, separate save action, optional links, mock attachment route, and repeated validation error. Fields autosave serially; confirmation writes a durable timestamp only after success. A failed confirmation stays unconfirmed, and failures remain recoverable after navigation.

The photo-ready state uses an isolated PNG fixture stored by the real evidence service. Photo library import/storage is implemented; direct camera capture and physical-device testing are outside this checkpoint. State fixtures and unit checks cover behavior; screenshots do not prove native taps. Saving/confirmation are held longer only in DEBUG capture scenarios. The automatic-next fixture calls the actual confirmation/advance path once.
