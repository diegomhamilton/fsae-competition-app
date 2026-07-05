//
//  FullStageViewState.swift
//  FSAEInspectionChecklist
//

import Foundation

struct FullStageViewState: Equatable, Sendable {
    let stageID: String
    let stageTitle: String
    let stageSubtitle: String
    let sections: [FullStageSectionViewState]

    init(
        stage: InspectionStage,
        draftsByTestCaseID: [String: TestCaseDraft] = [:]
    ) {
        stageID = stage.id
        stageTitle = stage.title
        stageSubtitle = stage.subtitle
        sections = stage.orderedSections.map { section in
            FullStageSectionViewState(
                stageID: stage.id,
                section: section,
                draftsByTestCaseID: draftsByTestCaseID
            )
        }
    }

    var testCaseCount: Int {
        sections.map(\.testCases.count).reduce(0, +)
    }

    var stepCount: Int {
        sections.flatMap(\.testCases).map(\.progressSummary.totalStepCount).reduce(0, +)
    }

    var completeStepCount: Int {
        sections.flatMap(\.testCases).map(\.progressSummary.completeStepCount).reduce(0, +)
    }

    var blockerCount: Int {
        sections.flatMap(\.testCases).map(\.validationSummary.blockerCount).reduce(0, +)
    }

    var progressFraction: Double {
        guard stepCount > 0 else { return 0 }
        return Double(completeStepCount) / Double(stepCount)
    }

    var progressText: String {
        "\(completeStepCount)/\(stepCount) complete"
    }

    var blockerText: String {
        switch blockerCount {
        case 0: "No blockers"
        case 1: "1 blocker"
        default: "\(blockerCount) blockers"
        }
    }

    var canSubmit: Bool {
        blockerCount == 0
    }

    var validationSummary: FullStageValidationSummary {
        FullStageValidationSummary(
            sections: sections,
            blockerCount: blockerCount
        )
    }
}

struct FullStageSectionViewState: Identifiable, Equatable, Sendable {
    let stageID: String
    let id: String
    let title: String
    let displayOrder: Int
    let testCases: [FullStageTestCaseViewState]

    init(
        stageID: String,
        section: InspectionSection,
        draftsByTestCaseID: [String: TestCaseDraft]
    ) {
        self.stageID = stageID
        id = section.id
        title = section.title
        displayOrder = section.displayOrder
        testCases = section.orderedTestCases.map { testCase in
            FullStageTestCaseViewState(
                testCase: testCase,
                draft: draftsByTestCaseID[testCase.id] ?? TestCaseDraft(testCase: testCase)
            )
        }
    }
}

struct FullStageTestCaseViewState: Identifiable, Equatable, Sendable {
    let testCase: InspectionTestCase
    let state: InspectionTestCaseViewState

    var id: String { testCase.id }
    var code: String { state.code }
    var title: String { state.title }
    var ruleReferences: [String] { state.ruleReferences }
    var progressSummary: InspectionTestCaseProgressSummary { state.progressSummary }
    var validationSummary: InspectionTestCaseValidationSummary { state.validationSummary }

    init(testCase: InspectionTestCase, draft: TestCaseDraft) {
        self.testCase = testCase
        self.state = InspectionTestCaseViewState(testCase: testCase, draft: draft)
    }
}

struct FullStageValidationSummary: Equatable, Sendable {
    let issues: [FullStageValidationIssue]
    let blockerCount: Int

    init(
        sections: [FullStageSectionViewState],
        blockerCount: Int
    ) {
        self.blockerCount = blockerCount
        issues = sections.flatMap { section in
            section.testCases.flatMap { testCase in
                testCase.validationSummary.issues.map { issue in
                    FullStageValidationIssue(
                        stageID: section.stageID,
                        testCaseID: testCase.id,
                        stepID: issue.stepID,
                        stepTitle: issue.stepTitle,
                        message: issue.localizedMessage,
                        issueID: issue.id
                    )
                }
            }
        }
    }

    var firstBlockingRoute: FullStageBlockingRoute? {
        issues.first.map {
            FullStageBlockingRoute(
                stageID: $0.stageID,
                testCaseID: $0.testCaseID,
                stepID: $0.stepID,
                issueID: $0.issueID
            )
        }
    }
}

struct FullStageValidationIssue: Identifiable, Equatable, Sendable {
    let stageID: String
    let testCaseID: String
    let stepID: String
    let stepTitle: String
    let message: String
    let issueID: String

    var id: String {
        issueID
    }
}

struct FullStageBlockingRoute: Equatable, Sendable {
    let stageID: String
    let testCaseID: String
    let stepID: String
    let issueID: String
}
