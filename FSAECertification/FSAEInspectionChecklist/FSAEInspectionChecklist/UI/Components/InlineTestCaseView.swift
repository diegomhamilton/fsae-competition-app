import SwiftUI
import SwiftData

struct InlineTestCaseView: View {
    @Environment(\.modelContext) private var modelContext
    let testCase: TestCase
    let session: InspectionSession
    var onVerdictSet: () -> Void

    @State private var viewModel: TestCaseDetailViewModel

    init(testCase: TestCase, session: InspectionSession, onVerdictSet: @escaping () -> Void) {
        self.testCase = testCase
        self.session = session
        self.onVerdictSet = onVerdictSet
        _viewModel = State(wrappedValue: TestCaseDetailViewModel(testCase: testCase, session: session))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            badges
            steps
            verdictPicker
        }
        .padding(.vertical, 6)
        .task {
            viewModel.configure(with: TestCaseResultService(modelContext: modelContext))
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack(alignment: .top, spacing: 10) {
            statusIcon
            VStack(alignment: .leading, spacing: 3) {
                Text(testCase.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                if let ruleRef = testCase.ruleRef {
                    Text(ruleRef)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            NavigationLink(value: testCase) {
                Image(systemName: "info.circle")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var badges: some View {
        if !testCase.badges.isEmpty {
            HStack(spacing: 6) {
                ForEach(testCase.badges, id: \.self) { badge in
                    Text(badge)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.15))
                        .foregroundStyle(Color.orange)
                        .clipShape(Capsule())
                }
            }
        }
    }

    @ViewBuilder
    private var steps: some View {
        if !viewModel.sortedSteps.isEmpty {
            VStack(spacing: 4) {
                ForEach(viewModel.sortedSteps) { step in
                    TestStepRowView(step: step)
                }
            }
        }
    }

    private var verdictPicker: some View {
        HStack(spacing: 0) {
            ForEach([TestCaseStatus.pass, .fail, .notApplicable], id: \.self) { status in
                let selected = viewModel.result?.status == status
                Button {
                    guard viewModel.result?.status != status else { return }
                    viewModel.setStatus(status)
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(350))
                        onVerdictSet()
                    }
                } label: {
                    Text(label(for: status))
                        .font(.subheadline)
                        .fontWeight(selected ? .semibold : .regular)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selected ? color(for: status) : Color.clear)
                        .foregroundStyle(selected ? .white : color(for: status))
                        .animation(.easeInOut(duration: 0.15), value: selected)
                }
                .buttonStyle(.plain)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private var statusIcon: some View {
        let (name, color) = iconInfo
        return Image(systemName: name)
            .font(.title3)
            .foregroundStyle(color)
            .frame(width: 24)
    }

    private var iconInfo: (String, Color) {
        switch viewModel.result?.status {
        case .pass:          return ("checkmark.circle.fill", .green)
        case .fail:          return ("xmark.circle.fill", .red)
        case .notApplicable: return ("minus.circle.fill", .secondary)
        default:             return ("circle", .secondary)
        }
    }

    private func label(for status: TestCaseStatus) -> String {
        switch status {
        case .pass:          return "Pass"
        case .fail:          return "Fail"
        case .notApplicable: return "N/A"
        case .pending:       return "—"
        }
    }

    private func color(for status: TestCaseStatus) -> Color {
        switch status {
        case .pass:          return .green
        case .fail:          return .red
        case .notApplicable: return .secondary
        case .pending:       return .secondary
        }
    }
}
