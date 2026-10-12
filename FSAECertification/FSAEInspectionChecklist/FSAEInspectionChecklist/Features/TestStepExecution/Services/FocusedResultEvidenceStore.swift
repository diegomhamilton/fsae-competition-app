import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Photo bytes are copied into the app container before metadata enters a draft,
/// so a photo does not depend on a temporary picker URL or library permission.
actor FocusedResultEvidenceStore {
    static let shared = FocusedResultEvidenceStore()
    nonisolated static let defaultDirectory = URL.applicationSupportDirectory.appending(path: "FSAEInspectionChecklist", directoryHint: .isDirectory)
    let baseDirectory: URL

    enum StoreError: Error {
        case invalidImage
        case invalidPath
    }

    init(baseDirectory: URL = FocusedResultEvidenceStore.defaultDirectory) {
        self.baseDirectory = baseDirectory
    }

    func storePhoto(_ data: Data, source: EvidenceAttachmentSource = .photoLibrary) throws -> EvidenceAttachmentMetadata {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              CGImageSourceGetCount(imageSource) > 0,
              let typeIdentifier = CGImageSourceGetType(imageSource) else {
            throw StoreError.invalidImage
        }
        let suffix = UTType(typeIdentifier as String)?.preferredFilenameExtension ?? "image"
        let id = UUID().uuidString
        let relativePath = "Evidence/\(id).\(suffix)"
        let directory = baseDirectory.appending(path: "Evidence", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: baseDirectory.appending(path: relativePath), options: .atomic)
        return EvidenceAttachmentMetadata(
            id: id,
            displayName: String(localized: "Photo evidence"),
            mediaType: .photo,
            source: source,
            createdAt: Date(),
            localRelativePath: relativePath
        )
    }

    func fileURL(for attachment: EvidenceAttachmentMetadata) throws -> URL {
        guard let path = attachment.localRelativePath,
              path.hasPrefix("Evidence/"),
              !path.contains(".."),
              !path.hasPrefix("/") else {
            throw StoreError.invalidPath
        }
        return baseDirectory.appending(path: path)
    }

    nonisolated static func localAssetAvailable(
        _ attachment: EvidenceAttachmentMetadata,
        baseDirectory: URL = defaultDirectory
    ) -> Bool {
        guard attachment.mediaType == .photo,
              let path = attachment.localRelativePath,
              path.hasPrefix("Evidence/"), !path.contains("..") else { return false }
        return FileManager.default.isReadableFile(atPath: baseDirectory.appending(path: path).path)
    }
}
