import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct InspectionTestCaseViewStateTests {
    @Test("US-002 test case view renders steps in display order")
    func us002TestCaseViewRendersStepsInDisplayOrder() {
        let viewState = InspectionTestCaseViewState(
            id: "rain-rml",
            code: "RAIN-RML",
            title: "Rain test RML behavior",
            ruleReferences: ["EV.6.1", "IN.11.3"],
            stepStates: [
                stepState(id: "RT-08", displayOrder: 30, title: "RML flashing"),
                stepState(id: "RT-01", displayOrder: 10, title: "PPE verified"),
                stepState(id: "RT-07", displayOrder: 20, title: "Activate TS")
            ]
        )

        #expect(viewState.steps.map(\.id) == ["RT-01", "RT-07", "RT-08"])
        #expect(viewState.steps.map(\.step.ruleReference) == ["EV.6.1", "EV.6.1", "EV.6.1"])
    }

    @Test("US-002/US-003/US-004 test case validation summary reports blockers")
    func us002Us003Us004TestCaseValidationSummaryReportsBlockers() {
        let viewState = InspectionTestCaseViewState(
            id: "blocked-case",
            code: "BLOCKED",
            title: "Blocked submission examples",
            ruleReferences: ["EV.6.1", "VE.5"],
            stepStates: [
                stepState(
                    id: "RT-08",
                    displayOrder: 10,
                    title: "RML flashing",
                    requiresEvidence: true,
                    outcome: .pass
                ),
                stepState(
                    id: "EG-14",
                    displayOrder: 20,
                    type: .measurement,
                    title: "Egress time",
                    outcome: .pass,
                    measurementInput: "5.40",
                    measurementRange: egressMeasurementRange()
                ),
                stepState(
                    id: "BP-01",
                    displayOrder: 30,
                    title: "Brake pedal travel",
                    outcome: .pending
                ),
                stepState(
                    id: "NF-01",
                    displayOrder: 40,
                    title: "Notes required",
                    outcome: .fail,
                    notes: ""
                )
            ]
        )

        #expect(viewState.validationSummary.blockerCount == 4)
        #expect(viewState.validationSummary.firstBlockingStepID == "RT-08")
        #expect(viewState.validationSummary.issues.map(\.code) == [
            .missingRequiredEvidence,
            .invalidMeasurement,
            .missingRequiredOutcome,
            .missingInspectorNote
        ])
        #expect(viewState.progressSummary.completeStepCount == 0)
        #expect(viewState.progressSummary.blockedStepCount == 4)
    }

    @Test("Accessibility identifier helpers build stable test case identifiers")
    func accessibilityIdentifierHelpersBuildStableTestCaseIdentifiers() {
        #expect(
            InspectionAccessibilityIdentifier.testCaseValidationSummary(testCaseID: "rain-rml").rawValue
                == "inspection.testCase.rain-rml.validation.summary"
        )
        #expect(
            InspectionAccessibilityIdentifier.testCaseStageSummary(stageID: "06_rain").rawValue
                == "inspection.stage.06_rain.summary"
        )
        #expect(
            InspectionAccessibilityIdentifier.testCaseStageValidationSummary(stageID: "06_rain").rawValue
                == "inspection.stage.06_rain.validation.summary"
        )
        #expect(
            InspectionAccessibilityIdentifier.testCaseStageSubmitAction(stageID: "06_rain").rawValue
                == "inspection.stage.06_rain.submit"
        )
        #expect(
            InspectionAccessibilityIdentifier.testCaseStageBlockedSubmitAction(stageID: "06_rain").rawValue
                == "inspection.stage.06_rain.submit.blocked"
        )
        #expect(
            InspectionAccessibilityIdentifier.testCaseStageSection(stageID: "06_rain", sectionID: "rain.primary").rawValue
                == "inspection.stage.06_rain.section.rain.primary"
        )
        #expect(
            InspectionAccessibilityIdentifier.testCaseStageRow(stageID: "06_rain", testCaseID: "rain-rml").rawValue
                == "inspection.stage.06_rain.testCase.rain-rml.row"
        )
        #expect(
            InspectionAccessibilityIdentifier.testCaseStageStatus(stageID: "06_rain", testCaseID: "rain-rml").rawValue
                == "inspection.stage.06_rain.testCase.rain-rml.status"
        )
        #expect(
            InspectionAccessibilityIdentifier.testCaseStageEnergizedBadge(stageID: "06_rain", testCaseID: "rain-rml").rawValue
                == "inspection.stage.06_rain.testCase.rain-rml.badge.energized"
        )
        #expect(
            InspectionAccessibilityIdentifier.testCaseStepRow(testCaseID: "rain-rml", stepID: "RT-08").rawValue
                == "inspection.testCase.rain-rml.step.RT-08.row"
        )
        #expect(
            InspectionAccessibilityIdentifier.testCaseStepOpenAction(testCaseID: "rain-rml", stepID: "RT-08").rawValue
                == "inspection.testCase.rain-rml.step.RT-08.open"
        )
        #expect(
            InspectionAccessibilityIdentifier.testCaseStepStatus(testCaseID: "rain-rml", stepID: "RT-08").rawValue
                == "inspection.testCase.rain-rml.step.RT-08.status"
        )
        #expect(
            InspectionAccessibilityIdentifier.testCaseKeyboardDismissAction(testCaseID: "rain-rml").rawValue
                == "inspection.testCase.rain-rml.keyboard.dismiss"
        )
    }

    @Test("Localizable string key helpers return structured keys for test case views")
    func localizableStringKeyHelpersReturnStructuredKeysForTestCaseViews() {
        #expect(InspectionTestCaseStrings.title.key == "inspection.testCase.title")
        #expect(InspectionTestCaseStrings.validationSummary.key == "inspection.testCase.validationSummary")
        #expect(InspectionTestCaseStrings.stepStatus.key(for: "RT-08") == "inspection.testCase.RT-08.stepStatus")
    }

    @Test("inspection-data test case step view state inherits energized safety badges from EV content")
    func inspectionDataTestCaseStepViewStateInheritsEnergizedSafetyBadgesFromEVContent() {
        let step = InspectionTestStep(
            id: "EV101.1",
            code: "EV101-1",
            displayOrder: 1,
            ruleReference: "EV.7.6",
            title: "Measure response",
            type: .measurement,
            content: "Measure response under energized conditions.",
            requiredOutcome: true,
            requiresEvidence: false
        )
        let state = InspectionTestCaseStepViewState(
            displayOrder: 1,
            step: step,
            inheritedSafetyBadges: [.energized],
            outcome: .pending,
            notes: "",
            measurementInput: "",
            evidenceAttachments: []
        )

        #expect(state.safetyBadges == [.energized])
    }
}

private func stepState(
    id: String,
    displayOrder: Int,
    type: InspectionTestStepType = .check,
    title: String,
    requiresEvidence: Bool = false,
    outcome: InspectionOutcome = .pending,
    notes: String = "",
    measurementInput: String = "",
    measurementRange: MeasurementRange? = nil
) -> InspectionTestCaseStepViewState {
    InspectionTestCaseStepViewState(
        displayOrder: displayOrder,
        step: InspectionTestStep(
            id: id,
            code: id,
            ruleReference: "EV.6.1",
            title: title,
            type: type,
            content: "Test content for \(title).",
            requiredOutcome: true,
            requiresEvidence: requiresEvidence,
            measurementRange: measurementRange
        ),
        inheritedSafetyBadges: [],
        outcome: outcome,
        notes: notes,
        measurementInput: measurementInput,
        evidenceAttachments: []
    )
}

private func egressMeasurementRange() -> MeasurementRange {
    MeasurementRange(
        unit: .seconds,
        minimum: decimal("0.00"),
        maximum: decimal("4.99"),
        maximumFractionDigits: 2
    )
}

private func decimal(_ rawValue: String) -> Decimal {
    Decimal(string: rawValue, locale: Locale(identifier: "en_US_POSIX")) ?? 0
}
