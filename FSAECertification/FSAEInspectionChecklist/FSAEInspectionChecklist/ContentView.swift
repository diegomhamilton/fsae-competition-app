import SwiftUI

struct ContentView: View {
    @State private var selectedTeam = MockInspectionData.teams[0]
    @State private var selectedStage = MockInspectionData.stages[0]
    @State private var selectedStep = MockInspectionData.steps[0]
    @State private var selectedScreen: ProposedScreen = .sessionSelector
    @State private var showingSwitchConfirmation = false

    var body: some View {
        TabView(selection: $selectedScreen) {
            NavigationStack {
                SessionSelectorView(
                    teams: MockInspectionData.teams,
                    selectedTeam: $selectedTeam,
                    selectedScreen: $selectedScreen
                )
            }
            .tabItem {
                Label("Sessions", systemImage: "person.2")
            }
            .tag(ProposedScreen.sessionSelector)

            NavigationStack {
                ActiveTeamDashboardView(
                    team: selectedTeam,
                    stages: MockInspectionData.stages,
                    selectedStage: $selectedStage,
                    selectedScreen: $selectedScreen,
                    showingSwitchConfirmation: $showingSwitchConfirmation
                )
            }
            .tabItem {
                Label("Team", systemImage: "gauge.with.dots.needle.50percent")
            }
            .tag(ProposedScreen.dashboard)

            NavigationStack {
                FullStageView(
                    team: selectedTeam,
                    stage: selectedStage,
                    steps: MockInspectionData.steps,
                    selectedStep: $selectedStep,
                    selectedScreen: $selectedScreen
                )
            }
            .tabItem {
                Label("Stage", systemImage: "checklist")
            }
            .tag(ProposedScreen.stageChecklist)

            NavigationStack {
                StepOverviewView(
                    step: selectedStep,
                    selectedScreen: $selectedScreen
                )
            }
            .tabItem {
                Label("Step", systemImage: "square.and.pencil")
            }
            .tag(ProposedScreen.stepDetail)
        }
        .tint(Color.fsaePrimary)
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingSwitchConfirmation) {
            TeamSwitchConfirmationView(
                currentTeam: selectedTeam,
                targetTeam: MockInspectionData.teams[1],
                isPresented: $showingSwitchConfirmation,
                selectedTeam: $selectedTeam,
                selectedScreen: $selectedScreen
            )
            .presentationDetents([.medium])
        }
    }
}

enum ProposedScreen: Hashable {
    case sessionSelector
    case dashboard
    case stageChecklist
    case stepDetail
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
