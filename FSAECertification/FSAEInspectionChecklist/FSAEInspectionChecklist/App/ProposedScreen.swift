//
//  ProposedScreen.swift
//  FSAEInspectionChecklist
//

enum ProposedScreen: Hashable {
    case sessionSelector
    case dashboard
    #if DEBUG
    case internalSettings
    #endif
    case stageChecklist
    case testCase
    case stepDetail

    static let topLevelJudgeLandmarks: [ProposedScreen] = [
        .sessionSelector,
        .dashboard,
        .stageChecklist
    ]
}
