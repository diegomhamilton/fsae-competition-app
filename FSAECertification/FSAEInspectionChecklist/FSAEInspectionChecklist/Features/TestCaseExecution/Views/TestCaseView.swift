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
        static let evidenceDeferred = "Evidence Deferred"
        static let addEvidence = "Add Evidence"
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
    @State private var activeStepID: String?
    @FocusState private var focusedNoteStepID: String?

    var body: some View {
        ScreenShell(
            title: testCase.title,
            subtitle: "\(team.carNumber) \(team.school) · \(stage.title) · \(Strings.subtitle)"
        ) {
            TestCaseHeader(testCase: testCase)

            TestCaseStepCarousel(
                stageID: stage.id,
                testCaseID: testCase.id,
                steps: testCase.steps,
                focusedNoteStepID: $focusedNoteStepID,
                scrollPosition: $stepScrollPosition,
                activeStepID: $activeStepID
            ) { step in
                openStepDetail(step)
            } updateStepDraft: { stepDraft in
                updateStepDraft(stepDraft)
            } advanceFromStep: { stepID in
                advanceToNextStep(after: stepID)
            } scrollToStep: { stepID in
                scrollToStep(stepID)
            }

            TestCaseValidationSummaryPanel(testCase: testCase)

        }
        .onAppear {
            activeStepID = activeStepID ?? testCase.steps.first?.id
        }
        .onChange(of: testCase.steps.map(\.id)) { _, stepIDs in
            guard let firstStepID = stepIDs.first else {
                return
            }

            activeStepID = firstStepID
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

        scrollToStep(testCase.steps[nextIndex].id)
    }

    private func scrollToStep(_ stepID: String) {
        focusedNoteStepID = nil
        activeStepID = stepID
        withAnimation(.snappy) {
            stepScrollPosition.scrollTo(id: stepID)
        }
    }
}

private struct TestCaseStepCarousel: View {
    let stageID: String
    let testCaseID: String
    let steps: [InspectionTestCaseStepViewState]
    let focusedNoteStepID: FocusState<String?>.Binding
    @Binding var scrollPosition: ScrollPosition
    @Binding var activeStepID: String?
    let openStepDetail: (InspectionTestStep) -> Void
    let updateStepDraft: (TestStepDraft) -> Void
    let advanceFromStep: (String) -> Void
    let scrollToStep: (String) -> Void

    private var activeIndex: Int {
        guard let activeStepID,
              let index = steps.firstIndex(where: { $0.id == activeStepID })
        else {
            return 0
        }

        return index
    }

    var body: some View {
        let showsAdjacentPreview = steps.count > 1
        let horizontalBleed: CGFloat = showsAdjacentPreview ? 20 : 0

        VStack(alignment: .leading, spacing: 10) {
            TestCaseStepCarouselControls(
                activeIndex: activeIndex,
                totalCount: steps.count,
                previousStepID: adjacentStepID(offset: -1),
                nextStepID: adjacentStepID(offset: 1)
            ) { stepID in
                scrollToStep(stepID)
            }

            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 14) {
                    ForEach(steps) { stepState in
                        TestCaseStepCarouselItem(showsAdjacentPreview: showsAdjacentPreview) {
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
            .contentMargins(.horizontal, horizontalBleed, for: .scrollContent)
            .onScrollTargetVisibilityChange(idType: String.self, threshold: 0.8) { visibleStepIDs in
                if let visibleStepID = visibleStepIDs.first {
                    activeStepID = visibleStepID
                }
            }
            .frame(alignment: .top)
            .padding(.horizontal, -horizontalBleed)

            TestCaseStepCarouselDots(
                steps: steps,
                activeStepID: activeStepID ?? steps.first?.id
            )
        }
    }

    private func adjacentStepID(offset: Int) -> String? {
        let index = activeIndex + offset

        guard steps.indices.contains(index) else {
            return nil
        }

        return steps[index].id
    }
}

private struct TestCaseStepCarouselControls: View {
    let activeIndex: Int
    let totalCount: Int
    let previousStepID: String?
    let nextStepID: String?
    let scrollToStep: (String) -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text("Step \(activeIndex + 1) of \(totalCount)")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.fsaeSecondaryText)

            Spacer()

            CarouselStepButton(systemImage: "chevron.left", stepID: previousStepID, scrollToStep: scrollToStep)
            CarouselStepButton(systemImage: "chevron.right", stepID: nextStepID, scrollToStep: scrollToStep)
        }
    }
}

private struct CarouselStepButton: View {
    let systemImage: String
    let stepID: String?
    let scrollToStep: (String) -> Void

    var body: some View {
        Button {
            if let stepID {
                scrollToStep(stepID)
            }
        } label: {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
                .frame(width: 30, height: 30)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(stepID == nil ? Color.fsaeSecondaryText.opacity(0.35) : Color.fsaePrimary)
        .disabled(stepID == nil)
    }
}

private struct TestCaseStepCarouselDots: View {
    let steps: [InspectionTestCaseStepViewState]
    let activeStepID: String?

    var body: some View {
        HStack(spacing: 6) {
            ForEach(steps) { step in
                Capsule()
                    .fill(step.id == activeStepID ? Color.fsaePrimary : Color.fsaeBorder)
                    .frame(width: step.id == activeStepID ? 18 : 6, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.snappy, value: activeStepID)
    }
}

private struct TestCaseStepCarouselItem<Content: View>: View {
    let showsAdjacentPreview: Bool
    let content: Content

    init(
        showsAdjacentPreview: Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.showsAdjacentPreview = showsAdjacentPreview
        self.content = content()
    }

    var body: some View {
        content
            .containerRelativeFrame(.horizontal) { length, _ in
                length * (showsAdjacentPreview ? 0.84 : 1)
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
                    Text(testCase.title)
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
            if (progress.pendingStepCount > 0) {
                Text("\(progress.pendingStepCount) \(TestCaseView.Strings.pending.lowercased())")
                    .font(.caption)
                    .foregroundStyle(Color.fsaeSecondaryText)
            }
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

                StatusPill(text: state.step.type.label, color: state.step.type.color)

                Spacer()

                HStack(spacing: 8) {
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
                        Image(systemName: "chevron.right.circle")
                            .font(.title3.weight(.semibold))
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.fsaePrimary)
                    .accessibilityLabel(TestCaseView.Strings.openStep)
                    .accessibilityIdentifier(
                        InspectionAccessibilityIdentifier.testCaseStepOpenAction(
                            testCaseID: testCaseID,
                            stepID: state.id
                        ).rawValue
                    )
                }
            }

            HStack {
                if state.step.requiresEvidence {
                    StatusPill(text: state.evidenceStatus.displayName, color: state.evidenceStatus.color)
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

            HStack(alignment: .center, spacing: 10) {
                TextField(TestCaseView.Strings.notes, text: $noteText, axis: .vertical)
                    .focused(focusedNoteStepID, equals: state.id)
                    .lineLimit(2...4)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(minHeight: 36, alignment: .center)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .background(Color.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.42), lineWidth: 1)
                    }
                    .accessibilityIdentifier(
                        InspectionAccessibilityIdentifier.testCaseNotesField(
                            testCaseID: testCaseID,
                            stepID: state.id
                        ).rawValue
                    )

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
                    Image(systemName: "plus")
                        .font(.headline.weight(.semibold))
                        .frame(width: 44, height: 36)
                        .background(Color.fsaePrimary.opacity(0.12), in: Capsule())
                        .overlay {
                            Capsule()
                                .stroke(Color.fsaePrimary.opacity(0.35), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.fsaePrimary)
                .accessibilityLabel(TestCaseView.Strings.addEvidence)
                .accessibilityIdentifier(
                    InspectionAccessibilityIdentifier.testCaseEvidenceAction(
                        testCaseID: testCaseID,
                        stepID: state.id
                    ).rawValue
                )
            }
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

private extension InspectionTestCaseEvidenceStatus {
    var displayName: String {
        switch self {
        case .notRequired:
            TestCaseView.Strings.evidence
        case .deferred:
            TestCaseView.Strings.evidenceDeferred
        case .attached(let count):
            count == 1 ? "1 Evidence" : "\(count) Evidence"
        }
    }

    var color: Color {
        switch self {
        case .notRequired, .attached:
            .fsaeBlue
        case .deferred:
            .fsaeAmber
        }
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
