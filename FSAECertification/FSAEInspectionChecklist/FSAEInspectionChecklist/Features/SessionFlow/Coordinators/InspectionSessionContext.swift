//
//  InspectionSessionContext.swift
//  FSAEInspectionChecklist
//

struct InspectionSessionContext: Equatable {
    let eventID: String
    let sessionID: String
    var team: InspectionTeam
    var activeStageID: String
    var hasUnsavedDraft: Bool
}

