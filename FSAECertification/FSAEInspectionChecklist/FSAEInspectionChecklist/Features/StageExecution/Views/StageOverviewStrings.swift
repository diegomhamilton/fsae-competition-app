enum StageOverviewStrings {
    static var currentTest: String { "Current".inspectionLocalized }
    static var updated: String { "Updated".inspectionLocalized }
    static var chooseTest: String { "Choose a test".inspectionLocalized }
    static var start: String { "Start inspection".inspectionLocalized }
    static var resume: String { "Continue inspection".inspectionLocalized }
    static var continueTest: String { "Continue current test".inspectionLocalized }
    static var review: String { "Review stage".inspectionLocalized }
    static var results: String { "Results".inspectionLocalized }
    static var resolve: String { "Needs attention".inspectionLocalized }
    static var ready: String { "All results confirmed".inspectionLocalized }
    static var readyDescription: String { "Check the results before submitting this stage.".inspectionLocalized }
    static var edit: String { "Edit result".inspectionLocalized }
    static var unconfirmed: String { "Not confirmed".inspectionLocalized }
    static var noTests: String { "There are no tests in this stage.".inspectionLocalized }
    static var unanswered: String { "Not started".inspectionLocalized }
    static var draft: String { "Draft".inspectionLocalized }
    static var passed: String { "Pass".inspectionLocalized }
    static var failed: String { "Fail".inspectionLocalized }
    static var flagged: String { "Needs review".inspectionLocalized }
    static var exception: String { "N/A".inspectionLocalized }
    static var expanded: String { "Expanded".inspectionLocalized }
    static var collapsed: String { "Collapsed".inspectionLocalized }
    static var photoUnavailable: String { "Photo unavailable".inspectionLocalized }

    static var testSections: String { "Test sections".inspectionLocalized }

    static func vehicle(_ team: InspectionTeam) -> String {
        "\(team.carNumber) · \(team.school)"
    }

    static func progress(confirmed: Int, total: Int) -> String {
        InspectionLocalization.format("%d of %d results confirmed", confirmed, total)
    }

    static func needsReview(_ count: Int) -> String {
        InspectionLocalization.format(count == 1 ? "%d result needs review" : "%d results need review", count)
    }

    static func notes(_ notes: String) -> String { InspectionLocalization.format("Notes: %@", notes) }
    static func photoCount(_ count: Int) -> String { count == 1 ? "1 photo".inspectionLocalized : InspectionLocalization.format("%d photos", count) }
    static func sectionCount(_ count: Int) -> String { count == 1 ? "1 test".inspectionLocalized : InspectionLocalization.format("%d tests", count) }
}
