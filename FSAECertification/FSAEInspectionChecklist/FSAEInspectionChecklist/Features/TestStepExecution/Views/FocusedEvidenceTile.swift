import SwiftUI
import UIKit

struct FocusedEvidenceTile: View {
    let attachment: EvidenceAttachmentMetadata
    let view: () -> Void
    let retake: () -> Void
    @State private var thumbnail: UIImage?
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: view) {
                Group {
                    if let thumbnail { Image(uiImage: thumbnail).resizable().scaledToFit() }
                    else { Label(FocusedResultStrings.viewPhotos, systemImage: "photo").frame(minHeight: 140) }
                }
                .frame(maxWidth: .infinity, maxHeight: 160)
                .clipShape(.rect(cornerRadius: 20))
            }
            .accessibilityLabel(FocusedResultStrings.viewPhotos)
            .accessibilityIdentifier("execution.evidence.preview.\(attachment.id)")
            Button(FocusedResultStrings.retake, systemImage: "camera.rotate", action: retake)
                .font(.title3.bold()).frame(minHeight: 48)
                .accessibilityIdentifier("execution.evidence.retake.\(attachment.id)")
        }
        .task(id: attachment.id) {
            if let data = try? await FocusedResultEvidenceStore.shared.thumbnailData(for: attachment) {
                thumbnail = UIImage(data: data)
            }
        }
    }
}
