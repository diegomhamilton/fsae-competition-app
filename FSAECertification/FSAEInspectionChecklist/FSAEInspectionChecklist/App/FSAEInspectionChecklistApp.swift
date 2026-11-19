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
                InspectionSnapshotHarness(scenario: scenario)
            } else {
                ContentView()
            }
            #else
            ContentView()
            #endif
        }
    }
}
