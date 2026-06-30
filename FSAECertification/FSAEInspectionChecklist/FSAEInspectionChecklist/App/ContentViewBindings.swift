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

    var activeStepBinding: Binding<InspectionTestStep> {
        Binding(
            get: { executionCoordinator?.activeStep ?? MockInspectionData.steps[0] },
            set: { step in
                appCoordinator.openTestStep(id: step.id)
            }
        )
    }

    var teamSwitchConfirmationBinding: Binding<Bool> {
        Binding(
            get: {
                guard let route = executionCoordinator?.route else {
                    return false
                }

                if case .teamSwitchConfirmation = route {
                    return true
                }

                return false
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

