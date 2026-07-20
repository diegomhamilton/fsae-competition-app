//
//  StageNavigationRoute.swift
//  FSAEInspectionChecklist
//

enum StageNavigationRoute: Hashable {
    case testCase(testCaseID: String)
    case testStep(testCaseID: String, stepID: String)
}
