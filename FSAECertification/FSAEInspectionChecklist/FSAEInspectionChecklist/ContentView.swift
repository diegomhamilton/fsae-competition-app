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
            Tab("Sessions", systemImage: "person.2", value: .sessionSelector) {
                NavigationStack {
                    SessionSelectorView(
                        teams: MockInspectionData.teams,
                        selectedTeam: $selectedTeam,
                        selectedScreen: $selectedScreen
                    )
                }
            }

            Tab("Team", systemImage: "gauge.with.dots.needle.50percent", value: .dashboard) {
                NavigationStack {
                    ActiveTeamDashboardView(
                        team: selectedTeam,
                        stages: stages,
                        selectedStage: $selectedStage,
                        selectedScreen: $selectedScreen,
                        showingSwitchConfirmation: $showingSwitchConfirmation
                    )
                }
            }

            Tab("Stage", systemImage: "checklist", value: .stageChecklist) {
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
            }

            Tab("Case", systemImage: "list.bullet.rectangle", value: .testCase) {
                NavigationStack {
                    TestCaseView(
                        team: selectedTeam,
                        stage: selectedStage,
                        testCase: selectedTestCase,
                        selectedStep: $selectedStep,
                        selectedScreen: $selectedScreen
                    )
                }
            }

            Tab("Step", systemImage: "square.and.pencil", value: .stepDetail) {
                NavigationStack {
                    StepOverviewView(
                        step: selectedStep,
                        safetyBadges: selectedStep.safetyBadges,
                        selectedScreen: $selectedScreen
                    )
                }
            }
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
