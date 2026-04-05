import Foundation
import SwiftData

enum TestStepType: String, Codable {
    case requirement
    case instruction
    case precondition
    case note
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
}
