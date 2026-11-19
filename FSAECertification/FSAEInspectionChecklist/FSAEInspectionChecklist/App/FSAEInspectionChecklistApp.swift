//
//  FSAEInspectionChecklistApp.swift
//  FSAEInspectionChecklist
//

import SwiftUI

@main
struct FSAEInspectionChecklistApp: App {
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            if let scenario = InspectionSnapshotScenario.current {
                InspectionSnapshotHarness(scenario: scenario, onExit: InspectionSnapshotLaunch.current.exit)
            } else {
                ContentView()
            }
            #else
            ContentView()
            #endif
        }
    }
}
