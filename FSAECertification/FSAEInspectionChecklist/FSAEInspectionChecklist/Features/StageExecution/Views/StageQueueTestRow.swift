import SwiftUI

struct StageQueueTestRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let state: InspectionTestCaseViewState
    let status: StageResultStatus
    var isCurrent = false
    let select: () -> Void

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout())

        Button(action: select) {
            layout {
                Text(state.title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                if status == .pass || status == .fail {
                    Image(systemName: status.symbol)
                        .foregroundStyle(status.color)
                } else {
                    StageResultBadge(status: status)
                }
                HStack {
                    if isCurrent {
                        StageCurrentTestBadge()
                    }
                    Image(systemName: "chevron.right").foregroundStyle(Color.fsaePrimary)
                }
                .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : nil, alignment: .trailing)
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
