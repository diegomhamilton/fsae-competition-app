import Foundation
import Testing
@testable import FSAEInspectionChecklist

struct FocusedResultEvidenceStoreTests {
    @Test("Legacy step drafts decode as unconfirmed")
    func legacyDraftIsUnconfirmed() throws {
        let data = Data("""
        {"stepID":"legacy","outcome":"pass","notes":"","measurementInput":"","evidenceAttachments":[]}
        """.utf8)
        let draft = try JSONDecoder().decode(TestStepDraft.self, from: data)
        #expect(draft.confirmedAt == nil)
        #expect(draft.flaggedForReview == nil)
    }
    @Test("Legacy evidence metadata remains decodable without an asset path")
    func legacyMetadataDecodes() throws {
        let data = Data("""
        {"id":"legacy","displayName":"Evidence 1","mediaType":"photo","source":"mockAttachment","createdAt":0}
        """.utf8)
        let attachment = try JSONDecoder().decode(EvidenceAttachmentMetadata.self, from: data)
        #expect(attachment.localRelativePath == nil)
        #expect(attachment.source == .mockAttachment)
    }

    @Test("Photo bytes and portable metadata survive draft serialization")
    func photoIsStoredBeforeMetadata() async throws {
        let directory = URL.temporaryDirectory.appending(path: "fsae-evidence-test-\(UUID().uuidString)", directoryHint: .isDirectory)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FocusedResultEvidenceStore(baseDirectory: directory)
        let png = try #require(Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aBEkAAAAASUVORK5CYII="))
        let attachment = try await store.storePhoto(png)
        let url = try await store.fileURL(for: attachment)
        #expect(try Data(contentsOf: url) == png)
        #expect(attachment.source == .photoLibrary)
        #expect(FocusedResultEvidenceStore.localAssetAvailable(attachment, baseDirectory: directory))
        let draft = TestStepDraft(stepID: "photo-step", outcome: .pass, evidenceAttachments: [attachment])
        let decoded = try JSONDecoder().decode(TestStepDraft.self, from: JSONEncoder().encode(draft))
        #expect(decoded.evidenceAttachments == [attachment])
        #expect(decoded.evidenceAttachments.first?.localRelativePath?.hasPrefix("Evidence/") == true)
    }

    @Test("Camera evidence persists real bytes and its source through serialization")
    func capturedPhotoRetainsCameraSource() async throws {
        let directory = URL.temporaryDirectory.appending(path: "fsae-camera-test-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FocusedResultEvidenceStore(baseDirectory: directory)
        let png = try #require(Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aBEkAAAAASUVORK5CYII="))
        let attachment = try await store.storePhoto(png, source: .camera)
        let url = try await store.fileURL(for: attachment)
        #expect(try Data(contentsOf: url) == png)
        let restored = try JSONDecoder().decode(EvidenceAttachmentMetadata.self, from: JSONEncoder().encode(attachment))
        #expect(restored.source == .camera)
        #expect(FocusedResultEvidenceStore.localAssetAvailable(restored, baseDirectory: directory))
    }

    @Test("Invalid image data is rejected and no fake photo metadata is produced")
    func invalidImageIsRejected() async throws {
        let directory = URL.temporaryDirectory.appending(path: "fsae-invalid-evidence-\(UUID().uuidString)")
        let store = FocusedResultEvidenceStore(baseDirectory: directory)
        await #expect(throws: FocusedResultEvidenceStore.StoreError.self) {
            try await store.storePhoto(Data("not an image".utf8))
        }
        #expect(!FileManager.default.fileExists(atPath: directory.path))
    }
}
