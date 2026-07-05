//
//  InspectionExecutionRoute.swift
//  FSAEInspectionChecklist
//

enum InspectionExecutionRoute: Equatable {
    case dashboard
    case stage(stageID: String)
    case testCase(stageID: String, testCaseID: String)
    case testStep(stageID: String, testCaseID: String, stepID: String)
    case teamSwitchConfirmation(currentTeamID: Int, targetTeamID: Int)
}

