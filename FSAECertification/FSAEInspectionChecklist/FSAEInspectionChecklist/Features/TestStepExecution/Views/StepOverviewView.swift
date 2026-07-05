//
//  StepOverviewView.swift
//  FSAEInspectionChecklist
//

import SwiftUI

struct StepOverviewView: View {
    fileprivate enum Strings {
        static let eyebrow = "SC-004 · SC-005 · SC-006 Step Details"
        static let subtitle = "One overview for outcome, notes, measurements, and evidence using mock JSON-compatible inspection test step data."
        static let outcome = "Outcome"
        static let measurement = "Measurement"
        static let measurementValue = "Value"
        static let notes = "Notes"
        static let dismissKeyboard = "Done"
        static let done = "Done"
        static let evidence = "Evidence"
        static let addEvidence = "Add Fake Attachment"
        static let required = "Required"
        static let optional = "Optional"
    }

    @ObservedObject var coordinator: InspectionExecutionCoordinator
    let completeStep: () -> Void
    @State private var selectedOutcome = InspectionOutcome.pending
    @State private var measurementValue = "4.72"
    @State private var noteText = "Observed by lead judge at station 3."
    @State private var evidenceAttachments: [EvidenceAttachmentMetadata] = []
    @FocusState private var isNotesFocused: Bool

    var body: some View {
        let step = currentStep

        ScreenShell(
            eyebrow: Strings.eyebrow,
            title: step.title,
            subtitle: Strings.subtitle
        ) {
            ContentPanel {
                HStack(alignment: .top) {
                    Image(systemName: step.type.symbol)
                        .font(.title.weight(.semibold))
                        .foregroundStyle(step.type.color)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            StatusPill(text: step.type.label, color: step.type.color)
                            StatusPill(text: step.ruleReference, color: .fsaeGray)
                            ForEach(step.safetyBadges, id: \.self) { badge in
                                StatusPill(text: badge.displayName, color: .fsaeRed)
                                    .accessibilityLabel(badge.accessibilityLabel)
                                    .accessibilityValue(badge.accessibilityLabel)
                            }
                        }
                        Text(step.content)
                            .font(.body)
                            .foregroundStyle(Color.fsaeText)
                    }
                }
            }

            ContentPanel {
                Text(Strings.outcome)
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
                Picker(Strings.outcome, selection: $selectedOutcome) {
                    ForEach(InspectionOutcome.allCases, id: \.self) { outcome in
                        Text(outcome.displayName).tag(outcome)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier(InspectionAccessibilityIdentifier.testStepOutcome(stepID: step.id, outcome: selectedOutcome).rawValue)
                .accessibilityValue(selectedOutcome.displayName)
            }

            if step.type == .measurement {
                ContentPanel {
                    Text(Strings.measurement)
                        .font(.headline)
                        .foregroundStyle(Color.fsaeText)
                    HStack {
                        TextField(Strings.measurementValue, text: $measurementValue)
                            .textFieldStyle(.roundedBorder)
                            .measurementKeyboard()
                            .accessibilityIdentifier(InspectionAccessibilityIdentifier.measurementField(stepID: step.id).rawValue)
                        Text(step.measurementRange?.unit.rawValue ?? "value")
                            .foregroundStyle(Color.fsaeSecondaryText)
                    }
                    Text(measurementHelpText)
                        .font(.footnote)
                        .foregroundStyle(Color.fsaeSecondaryText)
                }
            }

            ContentPanel {
                Text(Strings.notes)
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
                TextEditor(text: $noteText)
                    .focused($isNotesFocused)
                    .frame(minHeight: 110)
                    .padding(8)
                    .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
                    .accessibilityIdentifier(InspectionAccessibilityIdentifier.notesField(stepID: step.id).rawValue)
            }

            EvidenceOverview(
                stepID: step.id,
                requiresEvidence: step.requiresEvidence,
                attachments: $evidenceAttachments
            )

            Button {
                persistDraft()
                completeStep()
            } label: {
                Label(Strings.done, systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityIdentifier(InspectionAccessibilityIdentifier.doneAction(stepID: step.id).rawValue)
        }
        .onAppear {
            let draft = coordinator.activeStepDraft
            selectedOutcome = draft?.outcome ?? step.defaultOutcome
            measurementValue = draft?.measurementInput ?? measurementValue
            noteText = draft?.notes ?? (step.defaultNote.isEmpty ? noteText : step.defaultNote)
            evidenceAttachments = draft?.evidenceAttachments ?? step.evidenceAttachments
        }
        .onChange(of: selectedOutcome) { _, _ in
            persistDraft()
        }
        .onChange(of: measurementValue) { _, _ in
            persistDraft()
        }
        .onChange(of: noteText) { _, _ in
            persistDraft()
        }
        .onChange(of: evidenceAttachments) { _, _ in
            persistDraft()
        }
        .safeAreaInset(edge: .bottom) {
            if isNotesFocused {
                KeyboardDismissBar(title: Strings.dismissKeyboard) {
                    isNotesFocused = false
                }
            }
        }
        .navigationTitle("Step")
    }

    private var currentStep: InspectionTestStep {
        coordinator.activeStep ?? MockInspectionData.steps[0]
    }

    private var measurementHelpText: String {
        let step = currentStep
        guard let range = step.measurementRange else {
            return "Mock schema: numeric value with precision and range validation."
        }

        return "Allowed range: \(range.minimum) to \(range.maximum) \(range.unit.rawValue)."
    }

    private func persistDraft() {
        guard let testCaseID = coordinator.activeTestCase?.id else {
            return
        }

        let measurementInput = currentStep.measurementInput(from: measurementValue)
        let draft = TestStepDraft(
            stepID: currentStep.id,
            outcome: selectedOutcome,
            notes: noteText,
            measurementInput: measurementInput.rawValue,
            measurementValue: measurementInput.measurementValue,
            evidenceAttachments: evidenceAttachments
        )

        Task {
            await coordinator.saveStepDraft(draft, testCaseID: testCaseID)
        }
    }
}

private struct EvidenceOverview: View {
    let stepID: String
    let requiresEvidence: Bool
    @Binding var attachments: [EvidenceAttachmentMetadata]

    var body: some View {
        ContentPanel {
            HStack {
                Text(StepOverviewView.Strings.evidence)
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
                Spacer()
                StatusPill(
                    text: requiresEvidence ? StepOverviewView.Strings.required : StepOverviewView.Strings.optional,
                    color: requiresEvidence ? .fsaeRed : .fsaeGray
                )
                .accessibilityValue(requiresEvidence ? "Evidence required" : "Evidence optional")
            }

            if attachments.isEmpty {
                Text(requiresEvidence ? "No attachment metadata added." : "Attachment metadata optional.")
                    .font(.footnote)
                    .foregroundStyle(Color.fsaeSecondaryText)
            } else {
                EvidenceAttachmentGrid(attachments: attachments)
            }

            Button {
                attachments.append(
                    EvidenceAttachmentMetadata(
                        id: "fake-attachment-\(attachments.count + 1)",
                        displayName: "Fake attachment \(attachments.count + 1)",
                        mediaType: .photo,
                        source: .mockAttachment,
                        createdAt: Date()
                    )
                )
            } label: {
                Label(StepOverviewView.Strings.addEvidence, systemImage: "plus.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier(InspectionAccessibilityIdentifier.evidenceAction(stepID: stepID).rawValue)
        }
    }
}

private struct EvidenceAttachmentGrid: View {
    let attachments: [EvidenceAttachmentMetadata]

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 220), spacing: 12, alignment: .top)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            ForEach(attachments) { attachment in
                EvidenceAttachment(metadata: attachment)
                    .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct EvidenceAttachment: View {
    let metadata: EvidenceAttachmentMetadata

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: metadata.mediaType == .photo ? "photo" : "paperclip")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.fsaeBlue)
            Text(metadata.displayName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.fsaeText)
                .lineLimit(2)
                .truncationMode(.middle)
            Text(metadata.mediaType.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(Color.fsaeSecondaryText)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
        .accessibilityValue(metadata.accessibilityValue)
    }
}
