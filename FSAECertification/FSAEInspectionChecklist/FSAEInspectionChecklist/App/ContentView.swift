//
//  ContentView.swift
//  FSAEInspectionChecklist
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appCoordinator = AppCoordinator()

    var body: some View {
        ContentTabsView(appCoordinator: appCoordinator)
            .tint(Color.fsaePrimary)
            .preferredColorScheme(.light)
            .task {
                appCoordinator.completeMockLogin()
                await appCoordinator.restoreTeamCatalog()
                await loadInspectionContent()
            }
    }

    private func loadInspectionContent() async {
        do {
            let loadedStages = try await InspectionContentService().loadOfficialStages()
            appCoordinator.updateStages(loadedStages)
        } catch {
            appCoordinator.updateStages(MockInspectionData.stages)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
