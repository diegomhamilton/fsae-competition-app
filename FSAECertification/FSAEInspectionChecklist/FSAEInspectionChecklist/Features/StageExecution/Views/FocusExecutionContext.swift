import SwiftUI

struct FocusExecutionContext: View {
    private enum Strings {
        static let details = "View details"
    }

    let title: String
    let vehicle: InspectionTeam
    let position: Int
    let total: Int
    var showsDetails: () -> Void = {}
    var isBusy = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.largeTitle).bold()
                    .foregroundStyle(Color.fsaeText)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 8)
                Button(action: showsDetails) {
                    Image(systemName: "info.circle")
                        .font(.title2)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel(Strings.details)
                .accessibilityIdentifier("execution.details.open")
                .disabled(isBusy)
            }
            HStack {
                Text("\(vehicle.carNumber) · \(vehicle.school)")
                Spacer()
                Text("\(position) of \(total)").monospacedDigit()
            }
            .font(.title3)
            .foregroundStyle(Color.fsaeSecondaryText)
        }
        .padding(.vertical)
        .accessibilityIdentifier("execution.context")
    }
}
