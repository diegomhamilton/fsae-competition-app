import Foundation
import SwiftData

@Observable
final class ActiveSessionViewModel {
    var errorMessage: String?

    private var sessionService: InspectionSessionService?
    private var resultService: TestCaseResultService?

    func configure(with sessionService: InspectionSessionService, resultService: TestCaseResultService) {
        self.sessionService = sessionService
        self.resultService = resultService
    }

    func createSession(teamName: String, vehicleNumber: String, eventYear: Int) {
        do {
            try sessionService?.createSession(
                teamName: teamName,
                vehicleNumber: vehicleNumber,
                eventYear: eventYear
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func progress(for template: InspectionTemplate, in session: InspectionSession) -> (completed: Int, total: Int) {
        resultService?.progress(for: template, in: session) ?? (0, 0)
    }
}
