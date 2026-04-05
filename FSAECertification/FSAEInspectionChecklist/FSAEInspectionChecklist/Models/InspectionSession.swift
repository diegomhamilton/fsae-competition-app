import Foundation
import SwiftData

@Model
final class InspectionSession {
    var teamName: String
    var vehicleNumber: String
    var eventYear: Int
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var results: [TestCaseResult] = []

    init(teamName: String, vehicleNumber: String, eventYear: Int) {
        self.teamName = teamName
        self.vehicleNumber = vehicleNumber
        self.eventYear = eventYear
        self.createdAt = Date()
    }
}
