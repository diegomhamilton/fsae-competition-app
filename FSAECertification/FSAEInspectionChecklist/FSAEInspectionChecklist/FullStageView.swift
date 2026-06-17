import SwiftUI

struct FullStageView: View {
    private enum Strings {
        static let dismissKeyboard = "Done"
    }

    let team: InspectionTeam
    let stage: InspectionStage
    let steps: [InspectionTestStep]
    @Binding var selectedStep: InspectionTestStep
    @Binding var selectedScreen: ProposedScreen
    @FocusState private var focusedNoteStepID: String?

    var body: some View {
        ScreenShell(
            eyebrow: "SC-003 Stage",
            title: stage.title,
            subtitle: "\(team.carNumber) \(team.school) · verdicts, notes, and evidence are editable directly from the stage."
        ) {
            ContentPanel {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(stage.title)
                            .font(.headline)
                            .foregroundStyle(Color.fsaeText)
                        Text(stage.requiredOpenItems == 0 ? "This stage is ready to submit." : "\(stage.requiredOpenItems) blocker needs judge attention.")
                            .font(.subheadline)
                            .foregroundStyle(Color.fsaeSecondaryText)
                    }
                    Spacer()
                    StatusPill(text: stage.requiredOpenItems == 0 ? "Complete" : "\(stage.requiredOpenItems) blocker", color: stage.requiredOpenItems == 0 ? Color.fsaeGreen : Color.fsaeAmber)
                }
                ProgressView(value: stage.progress)
                    .tint(stage.requiredOpenItems == 0 ? Color.fsaeGreen : Color.fsaePrimary)
            }

            VStack(spacing: 14) {
                ForEach(steps) { step in
                    FullStageStepCard(
                        step: step,
                        focusedNoteStepID: $focusedNoteStepID
                    ) {
                        selectedStep = step
                        selectedScreen = .stepDetail
                    }
                }
            }

            Button {
            } label: {
                Label("Submit Stage", systemImage: "paperplane.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .safeAreaInset(edge: .bottom) {
            if focusedNoteStepID != nil {
                KeyboardDismissBar(title: Strings.dismissKeyboard) {
                    focusedNoteStepID = nil
                }
            }
        }
        .navigationTitle("Stage")
    }
}

private struct FullStageStepCard: View {
    let step: InspectionTestStep
    let focusedNoteStepID: FocusState<String?>.Binding
    let openStepDetail: () -> Void
    @State private var selectedOutcome: InspectionOutcome
    @State private var noteText: String
    @State private var measurementValue: String

    init(
        step: InspectionTestStep,
        focusedNoteStepID: FocusState<String?>.Binding,
        openStepDetail: @escaping () -> Void
    ) {
        self.step = step
        self.focusedNoteStepID = focusedNoteStepID
        self.openStepDetail = openStepDetail
        _selectedOutcome = State(initialValue: step.defaultOutcome)
        _noteText = State(initialValue: step.defaultNote)
        _measurementValue = State(initialValue: step.type == .measurement ? "4.72" : "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: step.type.symbol)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(step.type.color)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(step.code)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.fsaeSecondaryText)
                        StatusPill(text: step.type.label, color: step.type.color)
                        if step.requiresEvidence {
                            StatusPill(text: "Evidence", color: Color.fsaeBlue)
                        }
                    }
                    Text(step.title)
                        .font(.headline)
                        .foregroundStyle(Color.fsaeText)
                    Text(step.content)
                        .font(.footnote)
                        .foregroundStyle(Color.fsaeSecondaryText)
                }
                Spacer()
                Button {
                    openStepDetail()
                } label: {
                    Image(systemName: "chevron.right.circle")
                        .font(.title3.weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.fsaePrimary)
                .accessibilityLabel("Open Step Detail")
            }

            Picker("Verdict", selection: $selectedOutcome) {
                Text("Pass").tag(InspectionOutcome.pass)
                Text("Fail").tag(InspectionOutcome.fail)
                Text("N/A").tag(InspectionOutcome.notApplicable)
                Text("Pending").tag(InspectionOutcome.pending)
            }
            .pickerStyle(.segmented)

            if step.type == .measurement {
                HStack {
                    TextField("Value", text: $measurementValue)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Text(step.measurementRange?.unit.rawValue ?? "value")
                        .font(.subheadline)
                        .foregroundStyle(Color.fsaeSecondaryText)
                }
            }

            HStack(spacing: 10) {
                Button {
                } label: {
                    Label("Evidence", systemImage: step.requiresEvidence ? "camera.fill" : "paperclip")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                } label: {
                    Label(noteText.isEmpty ? "Add Note" : "Edit Note", systemImage: "note.text")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            TextField("Judge notes", text: $noteText, axis: .vertical)
                .focused(focusedNoteStepID, equals: step.id)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
        }
        .padding(14)
        .background(Color.fsaeSurface, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(selectedOutcome == .pending ? Color.fsaeAmber.opacity(0.5) : Color.fsaeBorder)
        }
    }
}
