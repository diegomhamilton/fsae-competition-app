enum StageOverviewStrings {
    static let chooseTest = "Choose a test"
    static let start = "Start next test"
    static let resume = "Resume next test"
    static let continueTest = "Continue current test"
    static let review = "Review results"
    static let results = "Results"
    static let resolve = "Needs attention"
    static let ready = "All results confirmed"
    static let readyDescription = "Check the results before submitting this stage."
    static let edit = "Edit result"
    static let unconfirmed = "Not confirmed"
    static let noTests = "There are no tests in this stage."
    static let unanswered = "Not started"
    static let draft = "Draft"
    static let recorded = "Recorded"
    static let passed = "Pass"
    static let failed = "Fail"
    static let flagged = "Flagged"
    static let exception = "N/A"
    static let expanded = "Expanded"
    static let collapsed = "Collapsed"
    static let photoUnavailable = "Photo unavailable"

    static func vehicle(_ team: InspectionTeam) -> String {
        "\(team.carNumber) · \(team.school)"
    }

    static func progress(confirmed: Int, total: Int) -> String {
        "\(confirmed) of \(total) results confirmed"
    }

    static func notes(_ notes: String) -> String { "Notes: \(notes)" }
    static func photoCount(_ count: Int) -> String { count == 1 ? "1 photo" : "\(count) photos" }
    static func sectionCount(_ count: Int) -> String { count == 1 ? "1 test" : "\(count) tests" }
}
