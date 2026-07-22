//
//  TestCaseView.swift
//  FSAEInspectionChecklist
//

import SwiftUI

struct TestCaseView: View {
    fileprivate enum Strings {
        static let eyebrow = "Test Case"
        static let subtitle = "Record outcomes, notes, measurements, evidence, and validation status for this case."
        static let rules = "Rules"
        static let validationReady = "Ready to submit"
        static let validationBlocked = "Validation blockers"
        static let noBlockers = "No blockers found for this test case."
        static let stepProgress = "Step progress"
        static let outcome = "Outcome"
        static let measurementValue = "Value"
        static let evidence = "Evidence"
        static let addEvidence = "Add Evidence"
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

        enum Accessibility {
            static let stageTitle = "Stage title"
            static let validationSummary = "Test case validation summary"
            static let stepRow = "Test case step"
            static let status = "Step status"
            static let energizedBadge = "Caution, energized dynamic test step"
        }
    }

    let team: InspectionTeam
    let stage: InspectionStage
    let testCase: InspectionTestCaseViewState
    let openStepDetail: (InspectionTestStep) -> Void
    let updateStepDraft: (TestStepDraft) -> Void
    @State private var stepScrollPosition = ScrollPosition()
    @FocusState private var focusedNoteStepID: String?

    var body: some View {
        ScreenShell(
            eyebrow: Strings.eyebrow,
            title: testCase.title,
            subtitle: "\(team.carNumber) \(team.school) · \(stage.title) · \(Strings.subtitle)"
        ) {
            TestCaseHeader(testCase: testCase)

            TestCaseValidationSummaryPanel(testCase: testCase)

            TestCaseStepCarousel(
                stageID: stage.id,
                testCaseID: testCase.id,
                steps: testCase.steps,
                focusedNoteStepID: $focusedNoteStepID,
                scrollPosition: $stepScrollPosition
            ) { step in
                openStepDetail(step)
            } updateStepDraft: { stepDraft in
                updateStepDraft(stepDraft)
            } advanceFromStep: { stepID in
                advanceToNextStep(after: stepID)
            }
        }
        .onChange(of: testCase.steps.map(\.id)) { _, stepIDs in
            guard let firstStepID = stepIDs.first else {
                return
            }

            stepScrollPosition.scrollTo(id: firstStepID)
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

    private func advanceToNextStep(after stepID: String) {
        guard let currentIndex = testCase.steps.firstIndex(where: { $0.id == stepID }) else {
            return
        }

        let nextIndex = testCase.steps.index(after: currentIndex)
        guard testCase.steps.indices.contains(nextIndex) else {
            return
        }

        focusedNoteStepID = nil
        withAnimation(.snappy) {
            stepScrollPosition.scrollTo(id: testCase.steps[nextIndex].id)
        }
    }
}

private struct TestCaseStepCarousel: View {
    let stageID: String
    let testCaseID: String
    let steps: [InspectionTestCaseStepViewState]
    let focusedNoteStepID: FocusState<String?>.Binding
    @Binding var scrollPosition: ScrollPosition
    let openStepDetail: (InspectionTestStep) -> Void
    let updateStepDraft: (TestStepDraft) -> Void
    let advanceFromStep: (String) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .top, spacing: 14) {
                ForEach(steps) { stepState in
                    TestCaseStepCarouselItem {
                        TestCaseStepCard(
                            stageID: stageID,
                            testCaseID: testCaseID,
                            state: stepState,
                            focusedNoteStepID: focusedNoteStepID
                        ) {
                            openStepDetail(stepState.step)
                        } updateStepDraft: { stepDraft in
                            updateStepDraft(stepDraft)
                        } advanceFromStep: {
                            advanceFromStep(stepState.id)
                        }
                    }
                    .id(stepState.id)
                }
            }
            .scrollTargetLayout()
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition($scrollPosition)
        .frame(minHeight: 430, alignment: .top)
    }
}

private struct TestCaseStepCarouselItem<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .containerRelativeFrame(.horizontal) { length, _ in
                length * 0.88
            }
            .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                content
                    .scaleEffect(phase.isIdentity ? 1 : 0.96)
                    .opacity(phase.isIdentity ? 1 : 0.82)
            }
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
                .accessibilityIdentifier(InspectionAccessibilityIdentifier.testCaseValidationSummary(testCaseID: testCase.id).rawValue)
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

    private var blockerRows: [ValidationBlockerOutlineRow] {
        [
            ValidationBlockerOutlineRow(
                id: "validation-blockers",
                blockerCount: testCase.validationSummary.blockerCount,
                children: testCase.validationSummary.issues.map(ValidationBlockerOutlineRow.init(issue:))
            )
        ]
    }

    var body: some View {
        ContentPanel {
            if testCase.validationSummary.isPassing {
                HStack(alignment: .firstTextBaseline) {
                    Text(TestCaseView.Strings.validationReady)
                        .font(.headline)
                        .foregroundStyle(Color.fsaeText)
                    Spacer()
                    StatusPill(
                        text: TestCaseView.Strings.complete,
                        color: .fsaeGreen
                    )
                }

                Text(TestCaseView.Strings.noBlockers)
                    .font(.footnote)
                    .foregroundStyle(Color.fsaeSecondaryText)
            } else {
                OutlineGroup(blockerRows, children: \.children) { row in
                    ValidationBlockerOutlineRowView(row: row)
                }
                .tint(Color.fsaeSecondaryText)
            }
        }
        .accessibilityIdentifier(InspectionAccessibilityIdentifier.testCaseValidationSummary(testCaseID: testCase.id).rawValue)
        .accessibilityValue(testCase.validationSummary.isPassing ? TestCaseView.Strings.validationReady : "\(testCase.validationSummary.blockerCount) blockers")
    }
}

private struct ValidationBlockerOutlineRow: Identifiable {
    let id: String
    let issue: InspectionTestCaseValidationIssue?
    let blockerCount: Int?
    var children: [ValidationBlockerOutlineRow]?

    init(
        id: String,
        blockerCount: Int,
        children: [ValidationBlockerOutlineRow]
    ) {
        self.id = id
        issue = nil
        self.blockerCount = blockerCount
        self.children = children
    }

    init(issue: InspectionTestCaseValidationIssue) {
        id = issue.id
        self.issue = issue
        blockerCount = nil
        children = nil
    }
}

private struct ValidationBlockerOutlineRowView: View {
    let row: ValidationBlockerOutlineRow

    var body: some View {
        if let issue = row.issue {
            Label {
                Text("\(issue.stepTitle): \(issue.localizedMessage)")
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
            }
            .font(.footnote)
            .foregroundStyle(Color.fsaeRed)
            .padding(.top, 4)
        } else {
            HStack(alignment: .firstTextBaseline) {
                Text(TestCaseView.Strings.validationBlocked)
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
                Spacer()
                StatusPill(
                    text: "\(row.blockerCount ?? 0) \(TestCaseView.Strings.blocked.lowercased())",
                    color: .fsaeRed
                )
            }
        }
    }
}

private struct TestCaseStepCard: View {
    let stageID: String
    let testCaseID: String
    let state: InspectionTestCaseStepViewState
    let focusedNoteStepID: FocusState<String?>.Binding
    let openStepDetail: () -> Void
    let advanceFromStep: () -> Void
    @State private var selectedOutcome: InspectionOutcome
    @State private var noteText: String
    @State private var measurementValue: String
    @State private var evidenceAttachments: [EvidenceAttachmentMetadata]

    init(
        stageID: String,
        testCaseID: String,
        state: InspectionTestCaseStepViewState,
        focusedNoteStepID: FocusState<String?>.Binding,
        openStepDetail: @escaping () -> Void,
        updateStepDraft: @escaping (TestStepDraft) -> Void,
        advanceFromStep: @escaping () -> Void
    ) {
        self.stageID = stageID
        self.testCaseID = testCaseID
        self.state = state
        self.focusedNoteStepID = focusedNoteStepID
        self.openStepDetail = openStepDetail
        self.updateStepDraft = updateStepDraft
        self.advanceFromStep = advanceFromStep
        _selectedOutcome = State(initialValue: state.outcome)
        _noteText = State(initialValue: state.notes)
        _measurementValue = State(initialValue: state.measurementInput)
        _evidenceAttachments = State(initialValue: state.evidenceAttachments)
    }

    private let updateStepDraft: (TestStepDraft) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: state.step.type.symbol)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(state.step.type.color)
                    .frame(width: 28)

                HStack {
                    Text(state.step.code)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.fsaeSecondaryText)
                    StatusPill(text: state.step.type.label, color: state.step.type.color)
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

            HStack {
                StatusPill(text: state.step.ruleReference, color: .fsaeGray)
                if state.step.requiresEvidence {
                    StatusPill(text: TestCaseView.Strings.evidence, color: Color.fsaeBlue)
                }
                ForEach(state.safetyBadges, id: \.self) { badge in
                    StatusPill(text: badge.displayName, color: .fsaeRed)
                        .accessibilityLabel(badge.accessibilityLabel)
                        .accessibilityValue(badge.accessibilityLabel)
                        .accessibilityIdentifier(
                            InspectionAccessibilityIdentifier.testCaseStageEnergizedBadge(
                                stageID: stageID,
                                testCaseID: testCaseID
                            ).rawValue
                        )
                }
            }

            Text(state.step.content)
                .font(.headline)
                .foregroundStyle(Color.fsaeText)

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
                        .measurementKeyboard()
                        .accessibilityIdentifier(InspectionAccessibilityIdentifier.measurementField(stepID: state.id).rawValue)
                    Text(state.step.measurementRange?.unit.rawValue ?? "value")
                        .font(.subheadline)
                        .foregroundStyle(Color.fsaeSecondaryText)
                }
            }

            HStack(spacing: 10) {
                Button {
                    evidenceAttachments.append(
                        EvidenceAttachmentMetadata(
                            id: "evidence-attachment-\(evidenceAttachments.count + 1)",
                            displayName: "Evidence \(evidenceAttachments.count + 1)",
                            mediaType: .photo,
                            source: .mockAttachment,
                            createdAt: Date()
                        )
                    )
                    persistDraft()
                } label: {
                    Label(TestCaseView.Strings.addEvidence, systemImage: state.step.requiresEvidence ? "camera.fill" : "paperclip")
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
        .onChange(of: selectedOutcome) { oldOutcome, newOutcome in
            persistDraft()
            #warning("PD: Review what flow makes more sense here")
            if oldOutcome == .pending, newOutcome.satisfiesRequiredOutcome {
                advanceFromStep()
            }
        }
        .onChange(of: noteText) { _, _ in
            persistDraft()
        }
        .onChange(of: measurementValue) { _, _ in
            persistDraft()
        }
        .onChange(of: state) { _, newState in
            syncLocalState(with: newState)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .background(Color.fsaeSurface.opacity(0.72), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(state.validationIssues.isEmpty ? Color.fsaeBorder : Color.fsaeRed.opacity(0.5))
        }
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.35), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 8)
        .accessibilityIdentifier(InspectionAccessibilityIdentifier.testCaseStepRow(testCaseID: testCaseID, stepID: state.id).rawValue)
    }

    private func syncLocalState(with state: InspectionTestCaseStepViewState) {
        if selectedOutcome != state.outcome {
            selectedOutcome = state.outcome
        }

        if noteText != state.notes {
            noteText = state.notes
        }

        if measurementValue != state.measurementInput {
            measurementValue = state.measurementInput
        }

        if evidenceAttachments != state.evidenceAttachments {
            evidenceAttachments = state.evidenceAttachments
        }
    }

    private func persistDraft() {
        let measurementInput = state.step.measurementInput(from: measurementValue)
        updateStepDraft(
            TestStepDraft(
                stepID: state.id,
                outcome: selectedOutcome,
                notes: noteText,
                measurementInput: measurementInput.rawValue,
                measurementValue: measurementInput.measurementValue,
                evidenceAttachments: evidenceAttachments
            )
        )
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

extension InspectionTestCaseValidationIssue {
    var localizedMessage: String {
        switch code {
        case .missingRequiredOutcome: TestCaseView.Strings.missingRequiredOutcome
        case .missingInspectorNote: TestCaseView.Strings.missingInspectorNote
        case .missingRequiredEvidence: TestCaseView.Strings.missingRequiredEvidence
        case .missingMeasurement: TestCaseView.Strings.missingMeasurement
        case .invalidMeasurement: TestCaseView.Strings.invalidMeasurement
        }
    }
}
