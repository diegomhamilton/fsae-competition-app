import SwiftUI

struct TeamSwitchConfirmationView: View {
    let currentTeam: InspectionTeam
    let targetTeam: InspectionTeam
    @Binding var isPresented: Bool
    @Binding var selectedTeam: InspectionTeam
    @Binding var selectedScreen: ProposedScreen

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Capsule()
                .fill(Color.black.opacity(0.18))
                .frame(width: 42, height: 5)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 8) {
                Text("SC-007 Team Switch")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.fsaePrimary)
                Text("Save Draft Before Switching?")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.fsaeText)
                Text("This proposal makes team switching explicit when the current session has unsaved inspection work.")
                    .font(.subheadline)
                    .foregroundStyle(Color.fsaeSecondaryText)
            }

            ContentPanel {
                Label("\(currentTeam.carNumber) \(currentTeam.school)", systemImage: "person.crop.circle.badge.checkmark")
                Label("\(targetTeam.carNumber) \(targetTeam.school)", systemImage: "arrow.right.circle")
                Label("Draft can be saved with the current stage pointer.", systemImage: "externaldrive.badge.checkmark")
            }

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button {
                    selectedTeam = targetTeam
                    selectedScreen = .dashboard
                    isPresented = false
                } label: {
                    Label("Save & Switch", systemImage: "checkmark.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(20)
        .background(Color.fsaeBackground)
    }
}
