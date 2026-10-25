# Confirmed advancement and motion

Implementation: PR 3, the feature commit containing this note. Captured on the FSAE UI Review iPhone 17 Pro simulator (iOS 26.2).

| Snapshot | Evidence |
| --- | --- |
| 01-next-test.png | Actual save-and-advance fixture opens DRIVER SUIT, 4 of 9. |
| 02-reduced-motion.png | Same save-and-advance sequence with the DEBUG Reduce Motion override; the transition is disabled. |
| 03-failed-save.png | Injected local write failure keeps ARM RESTRAINTS, 3 of 9, with Retry saving. |
| 04-transition.mp4 | Simulator recording of the actual save confirmation and next-test transition. |

These independent-branch captures retain the base input appearance. PR 1 supplies the larger input card. The three PRs are reviewed together in the integration report.

Validation: 17 coordinator and persistence tests passed in `/tmp/FSAE-pr3-green.xcresult`. The new sequence advances only after the coordinator confirms completion; a second attempt on an incomplete next step does not advance. The existing persistence gate and confirmation interval remain authoritative. Motion is presentation only and respects the system Reduce Motion setting. Static screenshots establish end states; use the recording to review motion. Physical-device gestures and VoiceOver interaction have not been manually exercised.
