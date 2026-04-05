import Foundation
import SwiftData

@Model
final class InspectionSection {
    var title: String
    var displayOrder: Int
    var template: InspectionTemplate?
    @Relationship(deleteRule: .cascade) var testCases: [TestCase] = []

    init(title: String, displayOrder: Int) {
        self.title = title
        self.displayOrder = displayOrder
    }
}
