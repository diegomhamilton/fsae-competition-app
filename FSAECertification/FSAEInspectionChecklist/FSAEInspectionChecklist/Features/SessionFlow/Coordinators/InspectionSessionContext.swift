//
//  InspectionSessionContext.swift
//  FSAEInspectionChecklist
//

import Foundation

struct InspectionSessionContext: Equatable {
    let eventID: String
    let sessionID: String
    var team: InspectionTeam
    var activeStageID: String
    var startedAt: Date
    var endedAt: Date?
    var hasUnsavedDraft: Bool
}
