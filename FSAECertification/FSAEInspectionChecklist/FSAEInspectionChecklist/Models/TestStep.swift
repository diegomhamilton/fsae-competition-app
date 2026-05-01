import Foundation
import SwiftData

enum TestStepType: String, Codable {
    case precondition
    case action
    case check
    case context
    case measurement
    case evidence
}

enum EvidenceType {
    case photo
    case video
    case audio
    case pdf
    case text
    case generic

    init(content: String) {
        let normalized = content.lowercased()

        if normalized.contains("[photo]") || normalized.contains("photo") || normalized.contains("image") || normalized.contains("picture") {
            self = .photo
        } else if normalized.contains("[video]") || normalized.contains("video") {
            self = .video
        } else if normalized.contains("[audio]") || normalized.contains("audio") || normalized.contains("mic") || normalized.contains("microphone") || normalized.contains("sound") || normalized.contains(".wav") || normalized.contains(" wav") || normalized.contains(".caf") || normalized.contains(" caf") {
            self = .audio
        } else if normalized.contains("[pdf]") || normalized.contains("pdf") || normalized.contains("document") {
            self = .pdf
        } else if normalized.contains("[text]") || normalized.contains("text") || normalized.contains("note") || normalized.contains("comment") {
            self = .text
        } else {
            self = .generic
        }
    }
}

@Model
final class TestStep {
    var displayOrder: Int
    var type: TestStepType
    var content: String
    var testCase: TestCase?

    init(displayOrder: Int, type: TestStepType, content: String) {
        self.displayOrder = displayOrder
        self.type = type
        self.content = content
    }

    var evidenceType: EvidenceType {
        guard type == .evidence else { return .generic }
        return EvidenceType(content: content)
    }
}
