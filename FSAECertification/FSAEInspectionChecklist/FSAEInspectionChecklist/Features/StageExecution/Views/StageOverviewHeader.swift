import SwiftUI

struct StageOverviewHeader: View {
    let team: InspectionTeam
    let confirmedCount: Int
    let totalCount: Int
    var needsReviewCount = 0
    var review: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading) {
            Text(StageOverviewStrings.vehicle(team)).font(.title2).bold()
            Text(StageOverviewStrings.progress(confirmed: confirmedCount, total: totalCount))
                .font(.subheadline)
                .foregroundStyle(Color.fsaeSecondaryText)
            ProgressView(value: totalCount == 0 ? 0 : Double(confirmedCount) / Double(totalCount))
                .tint(Color.fsaePrimary)
                .accessibilityLabel(StageOverviewStrings.progress(confirmed: confirmedCount, total: totalCount))
            if needsReviewCount > 0 {
                Label(StageOverviewStrings.needsReview(needsReviewCount), systemImage: "flag.fill")
                    .font(.subheadline)
                    .foregroundStyle(Color.fsaeAmber)
            }
            if let review {
                Button(StageOverviewStrings.review, systemImage: "checklist", action: review)
                    .frame(minHeight: 48)
                    .accessibilityIdentifier("execution.queue.review")
            }
        }
        .padding(.bottom)
        .accessibilityIdentifier("execution.overview.context")
    }
}
