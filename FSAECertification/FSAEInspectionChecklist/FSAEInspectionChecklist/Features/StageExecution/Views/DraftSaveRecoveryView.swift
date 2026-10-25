import SwiftUI

struct DraftSaveRecoveryView: View {
    private enum Strings {
        static let failure = "Some results could not be saved."
        static let retry = "Retry saving"
    }
    let hasFailedSave: Bool
    let retry: @MainActor () async -> Bool
    @State private var isRetrying = false

    var body: some View {
        if hasFailedSave {
            VStack(alignment: .leading) {
                Label(Strings.failure, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(Color.fsaeRed)
                Button {
                    guard !isRetrying else { return }
                    isRetrying = true
                    Task {
                        _ = await retry()
                        isRetrying = false
                    }
                } label: {
                    if isRetrying { ProgressView() }
                    else { Text(Strings.retry).frame(minHeight: 48) }
                }
                .disabled(isRetrying)
                .accessibilityIdentifier("execution.overview.save-retry")
            }
            .padding().frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.fsaeSurface)
        }
    }
}
