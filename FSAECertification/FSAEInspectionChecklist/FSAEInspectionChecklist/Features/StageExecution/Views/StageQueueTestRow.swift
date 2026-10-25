import SwiftUI

struct StageQueueTestRow: View {
    let state: InspectionTestCaseViewState
    let status: StageResultStatus
    var isCurrent = false
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            HStack {
                Text(state.title).font(.headline)
                Spacer()
                if status == .pass || status == .fail {
                    Image(systemName: status.symbol)
                        .foregroundStyle(status.color)
                } else {
                    StageResultBadge(status: status)
                }
                if isCurrent {
                    StageCurrentTestBadge()
                }
                Image(systemName: "chevron.right").foregroundStyle(Color.fsaePrimary)
            }
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .padding(.vertical)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
            .accessibilityHidden(true)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.fsaeText)
        .disabled(state.steps.isEmpty)
        .accessibilityLabel(state.title)
        .accessibilityValue(status.title)
        .accessibilityAddTraits(isCurrent ? .isSelected : [])
        .accessibilityIdentifier("execution.queue.test.\(state.id)")
    }
}
