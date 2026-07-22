//
//  StageNavigationRoute.swift
//  FSAEInspectionChecklist
//

enum StageNavigationRoute: Hashable {
    case testCase(testCaseID: String)
    case testStep(testCaseID: String, stepID: String)

    var testCaseID: String {
        switch self {
        case .testCase(let testCaseID),
             .testStep(let testCaseID, _):
            return testCaseID
        }
    }
}
