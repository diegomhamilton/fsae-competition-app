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
            get: { appCoordinator.selectedScreen == .stageChecklist ? .dashboard : appCoordinator.selectedScreen },
            set: { appCoordinator.selectScreen($0) }
        )
    }

    var stagePresentedBinding: Binding<Bool> {
        Binding(
            get: { appCoordinator.selectedScreen == .stageChecklist },
            set: { presented in
                if !presented && appCoordinator.selectedScreen == .stageChecklist {
                    appCoordinator.selectScreen(.dashboard)
                }
            }
        )
    }
}
