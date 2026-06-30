//
//  SessionSelectionCoordinator.swift
//  FSAEInspectionChecklist
//

import Combine

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

    init(teams: [InspectionTeam]) {
        self.teams = teams
    }

    func team(id teamID: Int) -> InspectionTeam? {
        teams.first { $0.id == teamID }
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

