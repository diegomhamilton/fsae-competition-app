import SwiftUI

struct FocusExecutionContext: View {
    let title: String
    let vehicle: InspectionTeam
    let position: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.largeTitle).bold()
                .foregroundStyle(Color.fsaeText)
                .accessibilityAddTraits(.isHeader)
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
