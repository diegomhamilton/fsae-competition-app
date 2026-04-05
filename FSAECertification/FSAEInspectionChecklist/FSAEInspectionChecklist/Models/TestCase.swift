import Foundation
import SwiftData

@Model
final class TestCase {
    var itemId: String
    var ruleRef: String?
    var title: String
    var displayOrder: Int
    var badges: [String]
    var section: InspectionSection?
    var template: InspectionTemplate?
    @Relationship(deleteRule: .cascade) var steps: [TestStep] = []

    init(
        itemId: String,
        ruleRef: String? = nil,
        title: String,
        displayOrder: Int,
        badges: [String] = []
    ) {
        self.itemId = itemId
        self.ruleRef = ruleRef
        self.title = title
        self.displayOrder = displayOrder
        self.badges = badges
    }
}
