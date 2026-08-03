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

}
