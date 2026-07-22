//
//  ContentViewBindings.swift
//  FSAEInspectionChecklist
//

import SwiftUI

@MainActor
struct ContentViewBindings {
    let appCoordinator: AppCoordinator

    var executionCoordinator: InspectionExecutionCoordinator? {
        appCoordinator.eventCoordinator.executionCoordinator
    }

    var selectedScreenBinding: Binding<ProposedScreen> {
        Binding(
            get: { appCoordinator.selectedScreen },
            set: { appCoordinator.selectScreen($0) }
        )
    }

    var teamSwitchConfirmationBinding: Binding<Bool> {
        Binding(
            get: {
                executionCoordinator?.pendingSwitchTarget != nil
            },
            set: { isPresented in
                if !isPresented {
                    appCoordinator.cancelTeamSwitch()
                }
            }
        )
    }

    var nextSwitchTeamID: Int? {
        guard let activeTeamID = executionCoordinator?.activeTeam.id else {
            return nil
        }

        return appCoordinator.eventCoordinator.sessionSelectionCoordinator.teams
            .first { $0.id != activeTeamID }?
            .id
    }
}
