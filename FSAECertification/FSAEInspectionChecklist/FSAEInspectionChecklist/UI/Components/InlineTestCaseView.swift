import SwiftUI
import SwiftData

struct ExpandableTestCaseRowView: View {
    @Environment(\.modelContext) private var modelContext
    let testCase: TestCase
    let session: InspectionSession
    let isExpanded: Bool
    var onTap: () -> Void
    var onVerdictSet: () -> Void

    @State private var viewModel: TestCaseDetailViewModel

    init(
        testCase: TestCase,
        session: InspectionSession,
        isExpanded: Bool,
        onTap: @escaping () -> Void,
        onVerdictSet: @escaping () -> Void
    ) {
        self.testCase = testCase
        self.session = session
        self.isExpanded = isExpanded
        self.onTap = onTap
        self.onVerdictSet = onVerdictSet
        _viewModel = State(wrappedValue: TestCaseDetailViewModel(testCase: testCase, session: session))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if isExpanded {
                expandedContent
                    .padding(.top, 10)
                    .transition(.opacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { if !isExpanded { onTap() } }
        .padding(.vertical, 4)
        .animation(.smooth, value: isExpanded)
        .task {
            viewModel.configure(with: TestCaseResultService(modelContext: modelContext))
        }
    }

    // MARK: - Header
    // Structure is identical in both states — only opacity changes, no layout shifts.

    private var header: some View {
        HStack(spacing: 12) {
            statusIcon

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(testCase.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    // Badges stay in layout; fade out when expanded to avoid reflow
                    ForEach(testCase.badges, id: \.self) { badge in
                        BadgeLabel(text: badge)
                            .opacity(isExpanded ? 0 : 1)
                    }
                }
                if let ruleRef = testCase.ruleRef {
                    Text(ruleRef)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Always in layout to hold space; fades in when expanded
            NavigationLink(value: testCase) {
                Image(systemName: "info.circle")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .opacity(isExpanded ? 1 : 0)
            .allowsHitTesting(isExpanded)
        }
    }

    // MARK: - Expanded content

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !testCase.badges.isEmpty {
                HStack(spacing: 6) {
                    ForEach(testCase.badges, id: \.self) { BadgeLabel(text: $0) }
                }
            }

            if !viewModel.sortedSteps.isEmpty {
                VStack(spacing: 4) {
                    ForEach(viewModel.sortedSteps) { TestStepRowView(step: $0) }
                }
            }

            verdictPicker
        }
    }

    // MARK: - Verdict picker

    private var verdictBinding: Binding<TestCaseStatus> {
        Binding(
            get: { viewModel.result?.status ?? .pending },
            set: { newStatus in
                guard viewModel.result?.status != newStatus else { return }
                viewModel.setStatus(newStatus)
                onVerdictSet()
            }
        )
    }

    private var verdictPicker: some View {
        Picker("Verdict", selection: verdictBinding) {
            Text("Pass").tag(TestCaseStatus.pass)
            Text("Fail").tag(TestCaseStatus.fail)
            Text("N/A").tag(TestCaseStatus.notApplicable)
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Helpers

    private var statusIcon: some View {
        let (name, clr) = iconInfo
        return Image(systemName: name)
            .font(.title3)
            .foregroundStyle(clr)
            .frame(width: 24)
            .contentTransition(.symbolEffect(.replace))
    }

    private var iconInfo: (String, Color) {
        switch viewModel.result?.status {
        case .pass:          return ("checkmark.circle.fill", .green)
        case .fail:          return ("xmark.circle.fill", .red)
        case .notApplicable: return ("minus.circle.fill", .secondary)
        default:             return ("circle", .secondary)
        }
    }
}

private struct BadgeLabel: View {
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
