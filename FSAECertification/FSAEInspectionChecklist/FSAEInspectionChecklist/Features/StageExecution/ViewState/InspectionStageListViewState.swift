//
//  InspectionStageListViewState.swift
//  FSAEInspectionChecklist
//

import Foundation
import SwiftUI

struct InspectionStageListViewState: Equatable, Sendable {
    let stageID: String
    let stageTitle: String
    let sections: [InspectionStageListSectionViewState]

    init(
        stage: InspectionStage,
        draftsByTestCaseID: [String: TestCaseDraft] = [:]
    ) {
        stageID = stage.id
        stageTitle = stage.title
        sections = stage.orderedSections.map { section in
            InspectionStageListSectionViewState(
                stageID: stage.id,
                section: section,
                draftsByTestCaseID: draftsByTestCaseID
            )
        }
    }

    var testCaseCount: Int {
        sections.map(\.rows.count).reduce(0, +)
    }

    var blockerCount: Int {
        sections.flatMap(\.rows).map(\.blockerCount).reduce(0, +)
    }

    var summaryText: String {
        "\(testCaseCount) test cases"
    }
}

struct InspectionStageListSectionViewState: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let displayOrder: Int
    let rows: [InspectionStageTestCaseRowState]

    init(
        stageID: String,
        section: InspectionSection,
        draftsByTestCaseID: [String: TestCaseDraft]
    ) {
        id = section.id
        title = section.title
        displayOrder = section.displayOrder
        rows = section.orderedTestCases.map { testCase in
            InspectionStageTestCaseRowState(
                stageID: stageID,
                testCase: testCase,
                draft: draftsByTestCaseID[testCase.id] ?? TestCaseDraft(testCase: testCase)
            )
        }
    }
}

struct InspectionStageTestCaseRowState: Identifiable, Equatable, Sendable {
    let stageID: String
    let testCase: InspectionTestCase
    let completedStepCount: Int
    let totalStepCount: Int
    let blockerCount: Int

    var id: String {
        testCase.id
    }

    var code: String {
        testCase.code
    }

    var title: String {
        testCase.title
    }

    var ruleReferences: [String] {
        testCase.allRuleReferences
    }

    var safetyBadges: [InspectionSafetyBadge] {
        testCase.displaySafetyBadges
    }

    var progressText: String {
        "\(completedStepCount)/\(totalStepCount) complete"
    }

    var blockerSummary: String {
        switch blockerCount {
        case 0: "No blockers"
        case 1: "1 blocker"
        default: "\(blockerCount) blockers"
        }
    }

    var status: InspectionStageTestCaseRowStatus {
        if blockerCount > 0 {
            return .blocked
        }

        return completedStepCount == totalStepCount ? .complete : .pending
    }

    init(
        stageID: String,
        testCase: InspectionTestCase,
        draft: TestCaseDraft
    ) {
        self.stageID = stageID
        self.testCase = testCase
        let progress = draft.progress
        completedStepCount = progress.completedStepCount
        totalStepCount = progress.totalStepCount
        blockerCount = progress.blockerCount
    }
}

enum InspectionStageTestCaseRowStatus: Equatable, Sendable {
    case blocked
    case complete
    case pending

    var displayName: String {
        switch self {
        case .blocked: "Blocked"
        case .complete: "Complete"
        case .pending: "Pending"
        }
    }

    var color: Color {
        switch self {
        case .blocked: .fsaeAmber
        case .complete: .fsaeGreen
        case .pending: .fsaeGray
        }
    }
}
