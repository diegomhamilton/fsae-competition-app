import SwiftUI

struct FocusExecutionContext: View {
    let title: String
    let vehicle: InspectionTeam
    let position: Int
    let total: Int
    var category: InspectionStageCategory?

    var body: some View {
        VStack(alignment: .leading) {
            Text(title.inspectionLocalized)
                .font(.largeTitle).bold()
                .foregroundStyle(Color.fsaeText)
                .accessibilityAddTraits(.isHeader)
            if let category {
                Text(category.title.inspectionLocalized)
                    .font(.subheadline)
                    .foregroundStyle(Color.fsaeSecondaryText)
            }
            HStack {
                Text("\(vehicle.carNumber) · \(vehicle.school)")
                Spacer()
                Text(InspectionLocalization.format("%d of %d", position, total)).monospacedDigit()
            }
            .font(.title3)
            .foregroundStyle(Color.fsaeSecondaryText)
        }
        .padding(.vertical)
        .accessibilityIdentifier("execution.context")
    }
}
