import SwiftUI

struct ContentView: View {
    @State private var selectedTeam = MockInspectionData.teams[0]
    @State private var selectedStage = MockInspectionData.stages[0]
    @State private var selectedTestCase = MockInspectionData.testCases[0]
    @State private var selectedStep = MockInspectionData.steps[0]
    @State private var stages = MockInspectionData.stages
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
                    stages: stages,
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
                StageChecklistView(
                    team: selectedTeam,
                    stage: selectedStage
                ) { testCase in
                    selectedTestCase = InspectionTestCaseViewState(testCase: testCase)
                    selectedStep = testCase.orderedSteps.first ?? selectedStep
                    selectedScreen = .testCase
                }
            }
            .tabItem {
                Label("Stage", systemImage: "checklist")
            }
            .tag(ProposedScreen.stageChecklist)

            NavigationStack {
                TestCaseView(
                    team: selectedTeam,
                    stage: selectedStage,
                    testCase: selectedTestCase,
                    selectedStep: $selectedStep,
                    selectedScreen: $selectedScreen
                )
            }
            .tabItem {
                Label("Case", systemImage: "list.bullet.rectangle")
            }
            .tag(ProposedScreen.testCase)

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
        .task {
            await loadInspectionContent()
        }
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

    private func loadInspectionContent() async {
        do {
            let loadedStages = try await InspectionContentService().loadOfficialStages()
            guard let firstStage = loadedStages.first else {
                return
            }

            stages = loadedStages
            selectedStage = firstStage
            if let firstTestCase = firstStage.orderedSections.first?.orderedTestCases.first {
                selectedTestCase = InspectionTestCaseViewState(testCase: firstTestCase)
                selectedStep = firstTestCase.orderedSteps.first ?? selectedStep
            }
        } catch {
            stages = MockInspectionData.stages
        }
    }
}

enum ProposedScreen: Hashable {
    case sessionSelector
    case dashboard
    case stageChecklist
    case testCase
    case stepDetail
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
