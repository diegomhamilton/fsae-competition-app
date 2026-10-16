import SwiftUI
import QuickLook

/// Separate from the result button so viewing a photo cannot open correction.
struct StageReviewEvidenceView: View {
    let attachments: [EvidenceAttachmentMetadata]
    let stepID: String
    @State private var previewURL: URL?
    @State private var previewURLs: [URL] = []
    var body: some View {
        let available = attachments.filter { FocusedResultEvidenceStore.localAssetAvailable($0) }
        if !attachments.isEmpty {
            VStack(alignment: .leading) {
                if !available.isEmpty {
                    Button {
                        Task {
                            var urls: [URL] = []
                            for attachment in available {
                                if let url = try? await FocusedResultEvidenceStore.shared.fileURL(for: attachment) { urls.append(url) }
                            }
                            previewURLs = urls
                            previewURL = urls.first
                        }
                    } label: {
                        Label(StageOverviewStrings.photoCount(available.count), systemImage: "photo")
                            .font(.title3).frame(minHeight: 48)
                    }
                    .accessibilityIdentifier("execution.review.evidence.\(stepID)")
                }
                if available.count != attachments.count {
                    Label(StageOverviewStrings.photoUnavailable, systemImage: "exclamationmark.triangle").foregroundStyle(Color.fsaeRed)
                }
            }
            .padding([.horizontal, .bottom], 20)
            .quickLookPreview($previewURL, in: previewURLs)
        }
    }
}
