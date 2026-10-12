import SwiftUI
import QuickLook

struct StageReviewStepRow: View {
    @State private var previewURL: URL?
    @State private var previewURLs: [URL] = []
    let state: InspectionTestCaseStepViewState
    let status: StageResultStatus
    let showTitle: Bool
    let showsEdit: Bool
    let edit: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                if showTitle {
                    Text(state.step.title).font(.callout).bold()
                    StageResultBadge(status: status)
                }
                if status == .flagged {
                    Label(state.outcome.displayName, systemImage: state.outcome == .fail ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .font(.callout)
                        .foregroundStyle(state.outcome.color)
                }
                if !state.measurementInput.isEmpty {
                    Text("\(state.measurementInput) \(state.step.measurementRange?.unit.symbol ?? "")")
                        .font(.callout)
                }
                if !state.notes.isEmpty {
                    Text(StageOverviewStrings.notes(state.notes)).font(.callout)
                }
                if !state.evidenceAttachments.isEmpty {
                    let availableCount = state.evidenceAttachments.filter { FocusedResultEvidenceStore.localAssetAvailable($0) }.count
                    if availableCount > 0 {
                        Button {
                            Task {
                                var urls: [URL] = []
                                for attachment in state.evidenceAttachments where FocusedResultEvidenceStore.localAssetAvailable(attachment) {
                                    if let url = try? await FocusedResultEvidenceStore.shared.fileURL(for: attachment) { urls.append(url) }
                                }
                                previewURLs = urls
                                previewURL = urls.first
                            }
                        } label: {
                            Label(StageOverviewStrings.photoCount(availableCount), systemImage: "photo")
                        }
                        .font(.callout).frame(minHeight: 48)
                        .accessibilityIdentifier("execution.review.evidence.\(state.id)")
                    }
                    if availableCount != state.evidenceAttachments.count {
                        Label(StageOverviewStrings.photoUnavailable, systemImage: "exclamationmark.triangle")
                            .font(.callout)
                            .foregroundStyle(Color.fsaeRed)
                    }
                }
            }
            Spacer()
            if showsEdit {
                Button(StageOverviewStrings.edit, systemImage: "pencil", action: edit)
                    .labelStyle(.iconOnly)
                    .frame(minWidth: 48, minHeight: 48)
                    .accessibilityIdentifier("execution.review.edit.\(state.id)")
            }
        }
        .frame(minHeight: showTitle ? 48 : 0)
        .padding(.vertical, showTitle ? 12 : 0)
        .quickLookPreview($previewURL, in: previewURLs)
    }
}
