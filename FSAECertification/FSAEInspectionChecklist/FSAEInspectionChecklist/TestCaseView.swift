import SwiftUI

struct TestCaseView: View {
    fileprivate enum Strings {
        static let eyebrow = "SC-003 Test Case"
        static let subtitle = "Ordered test steps, validation blockers, notes, measurements, and evidence from mock test case state."
        static let rules = "Rules"
        static let validationReady = "Ready to submit"
        static let validationBlocked = "Validation blockers"
        static let noBlockers = "No blockers found for this test case."
        static let stepProgress = "Step progress"
        static let outcome = "Outcome"
        static let measurementValue = "Value"
        static let evidence = "Evidence"
        static let addNote = "Add Note"
        static let editNote = "Edit Note"
        static let notes = "Judge notes"
        static let openStep = "Open Step"
        static let dismissKeyboard = "Done"
        static let complete = "Complete"
        static let blocked = "Blocked"
        static let pending = "Pending"
        static let missingRequiredOutcome = "Select an outcome before submission."
        static let missingInspectorNote = "Failed outcomes require judge notes."
        static let missingRequiredEvidence = "Required evidence metadata is missing."
        static let missingMeasurement = "Measurement value is required."
        static let invalidMeasurement = "Measurement is outside the allowed format or range."
    }

    let team: InspectionTeam
    let stage: InspectionStage
    let testCase: InspectionTestCaseViewState
    @Binding var selectedStep: InspectionTestStep
    @Binding var selectedScreen: ProposedScreen
    @FocusState private var focusedNoteStepID: String?

    var body: some View {
        ScreenShell(
            eyebrow: Strings.eyebrow,
            title: testCase.title,
            subtitle: "\(team.carNumber) \(team.school) · \(stage.title) · \(Strings.subtitle)"
        ) {
            TestCaseHeader(testCase: testCase)

            TestCaseValidationSummaryPanel(testCase: testCase)

            VStack(spacing: 14) {
                ForEach(testCase.steps) { stepState in
                    TestCaseStepCard(
                        testCaseID: testCase.id,
                        state: stepState,
                        focusedNoteStepID: $focusedNoteStepID
                    ) {
                        selectedStep = stepState.step
                        selectedScreen = .stepDetail
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if focusedNoteStepID != nil {
                KeyboardDismissBar(title: Strings.dismissKeyboard) {
                    focusedNoteStepID = nil
                }
                .accessibilityIdentifier(InspectionAccessibilityIdentifier.testCaseKeyboardDismissAction(testCaseID: testCase.id).rawValue)
            }
        }
        .navigationTitle("Test Case")
    }
}

private struct TestCaseHeader: View {
    let testCase: InspectionTestCaseViewState

    var body: some View {
        ContentPanel {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(testCase.code)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.fsaeSecondaryText)
                    Text(TestCaseView.Strings.rules)
                        .font(.headline)
                        .foregroundStyle(Color.fsaeText)
                    HStack {
                        ForEach(testCase.ruleReferences, id: \.self) { rule in
                            StatusPill(text: rule, color: .fsaeGray)
                        }
                    }
                }
                Spacer()
                TestCaseProgressBadge(progress: testCase.progressSummary)
            }

            ProgressView(value: testCase.progressSummary.fractionComplete)
                .tint(testCase.validationSummary.isPassing ? Color.fsaeGreen : Color.fsaePrimary)
                .accessibilityLabel(TestCaseView.Strings.stepProgress)
        }
    }
}

private struct TestCaseProgressBadge: View {
    let progress: InspectionTestCaseProgressSummary

    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            StatusPill(
                text: "\(progress.completeStepCount)/\(progress.totalStepCount) \(TestCaseView.Strings.complete)",
                color: progress.blockedStepCount == 0 ? .fsaeGreen : .fsaeAmber
            )
            Text("\(progress.pendingStepCount) \(TestCaseView.Strings.pending.lowercased())")
                .font(.caption)
                .foregroundStyle(Color.fsaeSecondaryText)
        }
    }
}

private struct TestCaseValidationSummaryPanel: View {
    let testCase: InspectionTestCaseViewState

    var body: some View {
        ContentPanel {
            HStack(alignment: .firstTextBaseline) {
                Text(testCase.validationSummary.isPassing ? TestCaseView.Strings.validationReady : TestCaseView.Strings.validationBlocked)
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
                Spacer()
                StatusPill(
                    text: testCase.validationSummary.isPassing ? TestCaseView.Strings.complete : "\(testCase.validationSummary.blockerCount) \(TestCaseView.Strings.blocked.lowercased())",
                    color: testCase.validationSummary.isPassing ? .fsaeGreen : .fsaeRed
                )
            }

            if testCase.validationSummary.isPassing {
                Text(TestCaseView.Strings.noBlockers)
                    .font(.footnote)
                    .foregroundStyle(Color.fsaeSecondaryText)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(testCase.validationSummary.issues) { issue in
                        Label {
                            Text("\(issue.stepTitle): \(issue.message)")
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                        }
                        .font(.footnote)
                        .foregroundStyle(Color.fsaeRed)
                    }
                }
            }
        }
        .accessibilityIdentifier(InspectionAccessibilityIdentifier.testCaseValidationSummary(testCaseID: testCase.id).rawValue)
        .accessibilityValue(testCase.validationSummary.isPassing ? TestCaseView.Strings.validationReady : "\(testCase.validationSummary.blockerCount) blockers")
    }
}

private struct TestCaseStepCard: View {
    let testCaseID: String
    let state: InspectionTestCaseStepViewState
    let focusedNoteStepID: FocusState<String?>.Binding
    let openStepDetail: () -> Void
    @State private var selectedOutcome: InspectionOutcome
    @State private var noteText: String
    @State private var measurementValue: String

    init(
        testCaseID: String,
        state: InspectionTestCaseStepViewState,
        focusedNoteStepID: FocusState<String?>.Binding,
        openStepDetail: @escaping () -> Void
    ) {
        self.testCaseID = testCaseID
        self.state = state
        self.focusedNoteStepID = focusedNoteStepID
        self.openStepDetail = openStepDetail
        _selectedOutcome = State(initialValue: state.outcome)
        _noteText = State(initialValue: state.notes)
        _measurementValue = State(initialValue: state.measurementInput)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: state.step.type.symbol)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(state.step.type.color)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(state.step.code)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.fsaeSecondaryText)
                        StatusPill(text: state.step.type.label, color: state.step.type.color)
                        StatusPill(text: state.step.ruleReference, color: .fsaeGray)
                        if state.step.requiresEvidence {
                            StatusPill(text: TestCaseView.Strings.evidence, color: Color.fsaeBlue)
                        }
                    }
                    Text(state.step.title)
                        .font(.headline)
                        .foregroundStyle(Color.fsaeText)
                    Text(state.step.content)
                        .font(.footnote)
                        .foregroundStyle(Color.fsaeSecondaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    StatusPill(text: state.status.displayName, color: state.statusColor)
                        .accessibilityIdentifier(
                            InspectionAccessibilityIdentifier.testCaseStepStatus(
                                testCaseID: testCaseID,
                                stepID: state.id
                            ).rawValue
                        )
                    Button {
                        openStepDetail()
                    } label: {
                        Label(TestCaseView.Strings.openStep, systemImage: "chevron.right.circle")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.fsaePrimary)
                    .accessibilityIdentifier(
                        InspectionAccessibilityIdentifier.testCaseStepOpenAction(
                            testCaseID: testCaseID,
                            stepID: state.id
                        ).rawValue
                    )
                }
            }

            Picker(TestCaseView.Strings.outcome, selection: $selectedOutcome) {
                ForEach(InspectionOutcome.allCases, id: \.self) { outcome in
                    Text(outcome.displayName).tag(outcome)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier(InspectionAccessibilityIdentifier.testStepOutcome(stepID: state.id, outcome: selectedOutcome).rawValue)
            .accessibilityValue(selectedOutcome.displayName)

            if state.step.type == .measurement {
                HStack {
                    TextField(TestCaseView.Strings.measurementValue, text: $measurementValue)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier(InspectionAccessibilityIdentifier.measurementField(stepID: state.id).rawValue)
                    Text(state.step.measurementRange?.unit.rawValue ?? "value")
                        .font(.subheadline)
                        .foregroundStyle(Color.fsaeSecondaryText)
                }
            }

            HStack(spacing: 10) {
                Button {
                } label: {
                    Label(TestCaseView.Strings.evidence, systemImage: state.step.requiresEvidence ? "camera.fill" : "paperclip")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.testCaseEvidenceAction(
                        testCaseID: testCaseID,
                        stepID: state.id
                    ).rawValue
                )

                Label(noteText.isEmpty ? TestCaseView.Strings.addNote : TestCaseView.Strings.editNote, systemImage: "note.text")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
                    .foregroundStyle(Color.fsaeSecondaryText)
            }

            TextField(TestCaseView.Strings.notes, text: $noteText, axis: .vertical)
                .focused(focusedNoteStepID, equals: state.id)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.testCaseNotesField(
                        testCaseID: testCaseID,
                        stepID: state.id
                    ).rawValue
                )
        }
        .padding(14)
        .background(Color.fsaeSurface, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(state.validationIssues.isEmpty ? Color.fsaeBorder : Color.fsaeRed.opacity(0.5))
        }
        .accessibilityIdentifier(InspectionAccessibilityIdentifier.testCaseStepRow(testCaseID: testCaseID, stepID: state.id).rawValue)
    }
}

private extension InspectionTestCaseStepViewState {
    var statusColor: Color {
        switch status {
        case .blocked: .fsaeRed
        case .complete: .fsaeGreen
        case .pending: .fsaeAmber
        }
    }
}

private extension InspectionTestCaseStepStatus {
    var displayName: String {
        switch self {
        case .blocked: TestCaseView.Strings.blocked
        case .complete: TestCaseView.Strings.complete
        case .pending: TestCaseView.Strings.pending
        }
    }
}

private extension InspectionTestCaseValidationIssue {
    var message: String {
        switch code {
        case .missingRequiredOutcome: TestCaseView.Strings.missingRequiredOutcome
        case .missingInspectorNote: TestCaseView.Strings.missingInspectorNote
        case .missingRequiredEvidence: TestCaseView.Strings.missingRequiredEvidence
        case .missingMeasurement: TestCaseView.Strings.missingMeasurement
        case .invalidMeasurement: TestCaseView.Strings.invalidMeasurement
        }
    }
}
