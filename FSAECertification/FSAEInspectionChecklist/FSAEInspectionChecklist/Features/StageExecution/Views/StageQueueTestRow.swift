import SwiftUI

struct StageQueueTestRow: View {
    let state: InspectionTestCaseViewState
    let status: StageResultStatus
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            HStack {
                VStack(alignment: .leading) {
                    Text(state.title).font(.headline)
                    StageResultBadge(status: status)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(Color.fsaePrimary)
            }
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .padding(.vertical)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.fsaeText)
        .disabled(state.steps.isEmpty)
        .accessibilityIdentifier("execution.queue.test.\(state.id)")
    }
}
