import SwiftUI

struct StepOverviewView: View {
    let step: InspectionStep
    @Binding var selectedScreen: ProposedScreen
    @State private var selectedOutcome = StepOutcome.pending
    @State private var measurementValue = "4.72"
    @State private var noteText = "Observed by lead judge at station 3."

    var body: some View {
        ScreenShell(
            eyebrow: "SC-004 · SC-005 · SC-006 Step Details",
            title: step.title,
            subtitle: "One overview for outcome, notes, measurements, and evidence so the app UI can be evaluated before state logic is split."
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
                        }
                        Text(step.content)
                            .font(.body)
                            .foregroundStyle(Color.fsaeText)
                    }
                }
            }

            ContentPanel {
                Text("Outcome")
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
                Picker("Outcome", selection: $selectedOutcome) {
                    Text("Pass").tag(StepOutcome.pass)
                    Text("Fail").tag(StepOutcome.fail)
                    Text("N/A").tag(StepOutcome.notApplicable)
                    Text("Pending").tag(StepOutcome.pending)
                }
                .pickerStyle(.segmented)
            }

            if step.type == .measurement {
                ContentPanel {
                    Text("Measurement")
                        .font(.headline)
                        .foregroundStyle(Color.fsaeText)
                    HStack {
                        TextField("Value", text: $measurementValue)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                        Text("seconds")
                            .foregroundStyle(Color.fsaeSecondaryText)
                    }
                    Text("Mock schema: numeric value with precision and range validation.")
                        .font(.footnote)
                        .foregroundStyle(Color.fsaeSecondaryText)
                }
            }

            ContentPanel {
                Text("Notes")
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
                TextEditor(text: $noteText)
                    .frame(minHeight: 110)
                    .padding(8)
                    .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
            }

            EvidenceOverview(requiresEvidence: step.requiresEvidence)

            Button {
                selectedScreen = .stageChecklist
            } label: {
                Label("Done", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .onAppear {
            selectedOutcome = step.outcome
            noteText = step.note.isEmpty ? noteText : step.note
        }
        .navigationTitle("Step")
    }
}

private struct EvidenceOverview: View {
    let requiresEvidence: Bool

    var body: some View {
        ContentPanel {
            HStack {
                Text("Evidence")
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
                Spacer()
                StatusPill(text: requiresEvidence ? "Required" : "Optional", color: requiresEvidence ? .fsaeRed : .fsaeGray)
            }

            HStack(spacing: 12) {
                EvidenceAttachment(title: "RML photo", subtitle: "IMG_2042 · 10:18", systemImage: "photo")
                EvidenceAttachment(title: "Judge initials", subtitle: "A. Maia", systemImage: "signature")
            }

            Button {
            } label: {
                Label("Add Evidence", systemImage: "plus.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct EvidenceAttachment: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.fsaeBlue)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.fsaeText)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(Color.fsaeSecondaryText)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
    }
}
