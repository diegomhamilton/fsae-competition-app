import SwiftUI

struct StageOverviewHeader: View {
    let team: InspectionTeam
    let confirmedCount: Int
    let totalCount: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(StageOverviewStrings.vehicle(team)).font(.title2).bold()
            Text(StageOverviewStrings.progress(confirmed: confirmedCount, total: totalCount))
                .font(.subheadline)
                .foregroundStyle(Color.fsaeSecondaryText)
            ProgressView(value: totalCount == 0 ? 0 : Double(confirmedCount) / Double(totalCount))
                .tint(Color.fsaePrimary)
                .accessibilityLabel(StageOverviewStrings.progress(confirmed: confirmedCount, total: totalCount))
        }
        .padding(.bottom)
        .accessibilityIdentifier("execution.overview.context")
    }
}
