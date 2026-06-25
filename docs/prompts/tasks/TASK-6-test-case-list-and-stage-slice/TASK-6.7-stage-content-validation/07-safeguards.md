# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `6.7 Manually validate Garage, EV, Egress, and Rain stage content against Design/Resources/InspectionEvent/*.json.`

Plan: `<paste operations>`

Review for:

- Claiming manual validation is complete without actual app evidence
- Marking OpenSpec TASK#6.7 complete when only a checklist exists
- Missing prerequisite check for TASK#6.1 through TASK#6.6
- Missing Garage, EV, Egress, or Rain stage coverage
- Missing stage, section, test case, or step ordering checks
- Missing rule reference preservation checks
- Missing progress, blockers, or submit-control checks
- Missing blocked-submit correction checks
- Missing energized badge visible and accessible checks
- Missing measurement, evidence, or failed-note validation coverage where applicable
- Missing positive, negative, or edge case labels
- Missing `.feature` scenario mapping
- Accessibility checks that rely only on visible text or color
- Automatic build/test execution despite the user-run build policy
- Scope creep into implementation fixes
- Commit titles longer than 52 characters
- PR title not starting with `TASK#6.7:`
- Prompt folder or validation docs mixed with unrelated files

Return blockers first, then recommendations, then a final go/no-go.
