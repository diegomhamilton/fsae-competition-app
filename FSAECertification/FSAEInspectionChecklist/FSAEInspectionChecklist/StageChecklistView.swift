import SwiftUI

struct StageChecklistView: View {
    let team: InspectionTeam
    let stage: InspectionStage
    let steps: [InspectionStep]
    @Binding var selectedStep: InspectionStep
    @Binding var selectedScreen: ProposedScreen

    var body: some View {
        ScreenShell(
            eyebrow: "SC-003 Stage Checklist",
            title: stage.title,
            subtitle: "\(team.carNumber) \(team.school) · ordered execution list with blockers surfaced before submission."
        ) {
            ContentPanel {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Submit readiness")
                            .font(.headline)
                            .foregroundStyle(Color.fsaeText)
                        Text("\(stage.requiredOpenItems) required items still need judge attention.")
                            .font(.subheadline)
                            .foregroundStyle(Color.fsaeSecondaryText)
                    }
                    Spacer()
                    CircularProgress(progress: stage.progress)
                }
            }

            VStack(spacing: 12) {
                ForEach(steps) { step in
                    Button {
                        selectedStep = step
                        selectedScreen = .stepDetail
                    } label: {
                        StepRow(step: step, isSelected: selectedStep == step)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
            } label: {
                Label(stage.requiredOpenItems == 0 ? "Stage Complete" : "Submit Stage", systemImage: stage.requiredOpenItems == 0 ? "checkmark.seal.fill" : "paperplane.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(stage.requiredOpenItems > 0)
        }
        .navigationTitle("Stage")
    }
}

private struct StepRow: View {
    let step: InspectionStep
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: step.type.symbol)
                .foregroundStyle(step.type.color)
                .font(.title3.weight(.semibold))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                Text(step.code)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.fsaeSecondaryText)
                    StatusPill(text: step.type.label, color: step.type.color)
                    if step.requiresEvidence {
                        StatusPill(text: "Evidence", color: .fsaeBlue)
                    }
                }
                Text(step.title)
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
                Text(step.content)
                    .font(.footnote)
                    .foregroundStyle(Color.fsaeSecondaryText)
                    .lineLimit(2)
            }
            Spacer()
            StatusPill(text: step.outcome.rawValue, color: step.outcome.color)
        }
        .padding(14)
        .background(Color.fsaeSurface, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.fsaePrimary : Color.fsaeBorder, lineWidth: isSelected ? 2 : 1)
        }
    }
}

private struct CircularProgress: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.black.opacity(0.08), lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.fsaePrimary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.fsaeText)
        }
        .frame(width: 58, height: 58)
    }
}
