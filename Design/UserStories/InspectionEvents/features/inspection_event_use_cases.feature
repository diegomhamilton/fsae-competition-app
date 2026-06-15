@inspection-events
Feature: FSAE EV technical inspection event workflows
  Judges need to run staged technical inspections for multiple teams while
  preserving draft work, validation integrity, evidence, and readable history.

  Background:
    Given the current event has an available team roster
    And the official inspection stages are available offline

  @US-001 @US-005 @FL-001
  Rule: A judge can start or resume the correct team inspection session

    Scenario: Start a new inspection session for a team
      Given team "UFPE Racing" has no started inspection session
      When the judge selects team "UFPE Racing"
      Then a new inspection session is created for that team
      And the active context shows team "UFPE Racing"
      And the current stage is "Garage Inspection"

    Scenario: Resume an in-progress inspection session
      Given team "Capibarib-E Racing" has an in-progress inspection session
      And the last saved context is stage "EV Inspection"
      When the judge selects team "Capibarib-E Racing"
      Then the prior inspection session is restored
      And the active context shows team "Capibarib-E Racing"
      And the current stage is "EV Inspection"

    Scenario: Resumable sessions are clearly identified
      Given the following team sessions exist:
        | team               | status      | current_stage     | last_saved      |
        | Capibarib-E Racing | in_progress | EV Inspection     | Saved 2 min ago |
        | UFPE Racing        | not_started | Garage Inspection | Not started     |
        | UFPE Electric      | blocked     | Rain Test         | Needs evidence  |
      When the judge opens the session selector
      Then each team shows its inspection status
      And team "Capibarib-E Racing" is labeled as resumable
      And team "UFPE Electric" is labeled as blocked

  @US-002 @FL-002
  Rule: A stage can be submitted only after required outcomes and notes are valid

    Scenario: Submit a completed stage
      Given the judge is inspecting team "Capibarib-E Racing"
      And every required step in "Garage Inspection" has an accepted outcome
      And each failed step that requires notes has notes
      When the judge submits stage "Garage Inspection"
      Then the stage is accepted for submission
      And a completed stage snapshot is available for review

    Scenario: Block submission when a required outcome is missing
      Given the judge is inspecting team "Capibarib-E Racing"
      And step "RT-08" requires an outcome
      But step "RT-08" has no outcome
      When the judge submits the current stage
      Then the stage submission is blocked
      And the validation summary identifies step "RT-08"
      And the judge can navigate to the first invalid step

    Scenario: Require notes for a failed step when policy requires them
      Given the judge is inspecting team "Capibarib-E Racing"
      And step "RML flashing" has outcome "Fail"
      And failed outcomes require inspector notes
      But step "RML flashing" has no notes
      When the judge submits the current stage
      Then the stage submission is blocked
      And step "RML flashing" shows that notes are required

  @US-003 @FL-003
  Rule: Measurement values are validated before they affect stage completion

    Scenario: Record a valid measurement
      Given the judge is editing measurement step "Egress time"
      And the allowed range is "0.00" to "4.99" seconds
      When the judge records measurement "4.38"
      Then the measurement is saved as draft data
      And the step no longer appears incomplete

    Scenario Outline: Reject invalid measurement values
      Given the judge is editing measurement step "Egress time"
      And the allowed range is "0.00" to "4.99" seconds
      When the judge records measurement "<value>"
      Then the measurement is rejected with reason "<reason>"
      And the previous valid measurement remains unchanged

      Examples:
        | value | reason              |
        | fast  | non-numeric format  |
        | 4.999 | precision exceeded  |
        | 5.40  | outside valid range |

  @US-004 @FL-004
  Rule: Evidence requirements gate submission when proof is required

    Scenario: Attach evidence metadata to a step
      Given the judge is editing evidence step "RML flashing"
      When the judge adds attachment metadata "rml-visible-photo"
      Then the attachment metadata is visible on the step
      And the evidence requirement for "RML flashing" is satisfied

    Scenario: Block stage submission when required evidence is missing
      Given the judge is inspecting team "Capibarib-E Racing"
      And step "RML flashing" requires evidence
      But step "RML flashing" has no attachment metadata
      When the judge submits the current stage
      Then the stage submission is blocked
      And the validation summary identifies missing evidence for "RML flashing"

    Scenario: Removing required evidence makes the step invalid again
      Given the judge is editing evidence step "RML flashing"
      And attachment metadata "rml-visible-photo" is present
      When the judge removes attachment metadata "rml-visible-photo"
      Then the evidence requirement for "RML flashing" is unsatisfied
      And the stage cannot be submitted until evidence is restored

  @US-006 @FL-005
  Rule: Switching teams preserves drafts and isolates team context

    Scenario: Confirm a team switch with unsaved work
      Given the judge is inspecting team "Capibarib-E Racing"
      And the current team has unsaved draft changes
      When the judge switches to team "UFPE Racing"
      Then the app asks the judge to confirm the switch
      And the current draft is saved before the new team is loaded

    Scenario: Load only the selected team's inspection data after switching
      Given team "Capibarib-E Racing" has draft notes for step "RT-08"
      And team "UFPE Racing" has no draft notes for step "RT-08"
      When the judge switches from team "Capibarib-E Racing" to team "UFPE Racing"
      Then the active context shows team "UFPE Racing"
      And step "RT-08" has no notes for team "UFPE Racing"

    Scenario: Restore the previous team's exact draft context
      Given the judge switched away from team "Capibarib-E Racing"
      And team "Capibarib-E Racing" had draft notes for step "RT-08"
      And team "Capibarib-E Racing" was on stage "EV Inspection"
      When the judge switches back to team "Capibarib-E Racing"
      Then the active context shows stage "EV Inspection"
      And step "RT-08" shows the saved draft notes

  @US-007 @FL-006
  Rule: Historical submissions are visible but immutable

    Scenario: Review a historical submission
      Given team "Capibarib-E Racing" has a submitted "Garage Inspection" snapshot
      When the reviewer opens the submission history for team "Capibarib-E Racing"
      And the reviewer selects the "Garage Inspection" snapshot
      Then the snapshot shows stage outcomes, notes, and evidence references
      And the snapshot controls are read-only

    Scenario: Show an empty history state
      Given team "UFPE Racing" has no submitted snapshots
      When the reviewer opens the submission history for team "UFPE Racing"
      Then the history view shows that no submissions are available
      And no editable inspection controls are shown

  @inspection-data
  Rule: The official inspection stages are available to the judge offline

    Scenario: View the ordered inspection stages
      When the judge opens the active team dashboard
      Then the following inspection stages are shown in order:
        | order | stage               |
        | 1     | Garage Inspection   |
        | 2     | Body Inspection     |
        | 3     | Chassis Inspection  |
        | 4     | EV Inspection       |
        | 5     | Egress Test         |
        | 6     | Rain Test           |

    Scenario: Highlight energized dynamic test steps
      Given an EV inspection step belongs to the energized dynamic test range
      When the judge views the step in the checklist
      Then the step shows a visible "CAUTION: ENERGIZED" safety badge
