//
//  SessionSelectionCoordinator.swift
//  FSAEInspectionChecklist
//

import Combine
import Foundation

nonisolated struct CompletedSessionSummary: Identifiable, Equatable, Sendable {
    let id: String
    let startedAt: Date
    let endedAt: Date

    init?(session: InspectionSessionRecord) {
        guard session.status == .submitted, let endedAt = session.endedAt else {
            return nil
        }

        id = session.id
        startedAt = session.startedAt
        self.endedAt = endedAt
    }

    var startedAtText: String {
        "Started \(startedAt.formatted(date: .abbreviated, time: .shortened))"
    }

    var endedAtText: String {
        "Ended \(endedAt.formatted(date: .abbreviated, time: .shortened))"
    }

    var accessibilitySummary: String {
        "Completed session. \(startedAtText). \(endedAtText). Read-only."
    }
}

nonisolated struct SessionHistoryViewState: Equatable, Sendable {
    let entries: [CompletedSessionSummary]

    var isEmpty: Bool {
        entries.isEmpty
    }

    var emptyStateText: String {
        "No completed sessions yet."
    }
}

enum SessionSelectionRoute: Equatable {
    case roster
    case startNewSession(teamID: Int)
    case resumeSession(teamID: Int)
    case blocked(teamID: Int)
}

enum SessionSelectionIntent: Equatable {
    case startNewSession(InspectionTeam)
    case resumeSession(InspectionTeam)
    case blocked(InspectionTeam)
}

@MainActor
final class SessionSelectionCoordinator: ObservableObject {
    @Published private(set) var teams: [InspectionTeam]
    @Published private(set) var selectedTeamID: Int?
    @Published private(set) var route: SessionSelectionRoute = .roster
    @Published private(set) var historyByTeamID: [Int: SessionHistoryViewState] = [:]

    init(teams: [InspectionTeam]) {
        self.teams = teams
    }

    func team(id teamID: Int) -> InspectionTeam? {
        teams.first { $0.id == teamID }
    }

    func updateTeams(_ teams: [InspectionTeam]) {
        self.teams = teams
        if let selectedTeamID,
           !teams.contains(where: { $0.id == selectedTeamID }) {
            self.selectedTeamID = nil
            route = .roster
        }
    }

    func replaceHistory(_ historyByTeamID: [Int: SessionHistoryViewState]) {
        self.historyByTeamID = historyByTeamID
    }

    func history(for teamID: Int) -> SessionHistoryViewState {
        historyByTeamID[teamID] ?? SessionHistoryViewState(entries: [])
    }

    @discardableResult
    func selectTeam(id teamID: Int) -> SessionSelectionIntent? {
        guard let team = team(id: teamID) else {
            return nil
        }

        selectedTeamID = teamID

        switch team.status {
        case .ready:
            route = .startNewSession(teamID: teamID)
            return .startNewSession(team)
        case .resumed:
            route = .resumeSession(teamID: teamID)
            return .resumeSession(team)
        case .blocked:
            route = .blocked(teamID: teamID)
            return .blocked(team)
        }
    }
}
