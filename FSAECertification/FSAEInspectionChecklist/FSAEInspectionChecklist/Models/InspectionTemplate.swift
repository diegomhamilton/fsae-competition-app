import Foundation
import SwiftData

@Model
final class InspectionTemplate {
    var code: String
    var title: String
    var displayOrder: Int
    @Relationship(deleteRule: .cascade) var sections: [InspectionSection] = []
    @Relationship(deleteRule: .cascade) var testCases: [TestCase] = []

    init(code: String, title: String, displayOrder: Int) {
        self.code = code
        self.title = title
        self.displayOrder = displayOrder
    }
}
