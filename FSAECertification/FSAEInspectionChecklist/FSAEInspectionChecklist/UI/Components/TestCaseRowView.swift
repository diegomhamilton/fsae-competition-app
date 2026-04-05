import SwiftUI

struct TestCaseRowView: View {
    let testCase: TestCase
    let result: TestCaseResult?

    var body: some View {
        HStack(spacing: 12) {
            statusIcon
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(testCase.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    ForEach(testCase.badges, id: \.self) { badge in
                        BadgeView(text: badge)
                    }
                }
                if let ruleRef = testCase.ruleRef {
                    Text(ruleRef)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private var statusIcon: some View {
        let (name, color) = iconInfo
        return Image(systemName: name)
            .font(.title3)
            .foregroundStyle(color)
            .frame(width: 24)
    }

    private var iconInfo: (String, Color) {
        switch result?.status {
        case .pass:        return ("checkmark.circle.fill", .green)
        case .fail:        return ("xmark.circle.fill", .red)
        case .notApplicable: return ("minus.circle.fill", .secondary)
        default:           return ("circle", .secondary)
        }
    }
}

private struct BadgeView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.orange.opacity(0.15))
            .foregroundStyle(Color.orange)
            .clipShape(Capsule())
    }
}
