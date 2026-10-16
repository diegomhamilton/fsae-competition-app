import Foundation
import Observation

/// Navigation-owned overview state survives the queue sheet and correction view.
@MainActor @Observable
final class StageOverviewPresentation {
    var expandedSectionIDs: Set<String>
    private(set) var queueOffset: Double = 0
    private(set) var reviewOffset: Double = 0
    private(set) var queueRevealID: String?
    var lastCorrectedCaseID: String?

    init(firstSectionID: String?) {
        expandedSectionIDs = firstSectionID.map { [$0] } ?? []
    }
    func toggleSection(_ id: String) {
        if !expandedSectionIDs.insert(id).inserted { expandedSectionIDs.remove(id) }
    }
    func prepareQueue(testCaseID: String?, sectionID: String?) {
        queueRevealID = testCaseID
        if let sectionID, testCaseID != nil { expandedSectionIDs.insert(sectionID) }
    }
    func rememberQueueOffset(_ value: Double) {
        if value.isFinite && value >= 0 { queueOffset = value }
    }
    func rememberReviewOffset(_ value: Double) {
        if value.isFinite && value >= 0 { reviewOffset = value }
    }
}
