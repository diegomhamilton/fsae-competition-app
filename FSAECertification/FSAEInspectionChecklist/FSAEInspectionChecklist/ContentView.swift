import SwiftUI

struct ContentView: View {
    @StateObject private var appCoordinator = AppCoordinator()

    var body: some View {
        TabView(selection: selectedScreenBinding) {
            Tab("Sessions", systemImage: "person.2", value: .sessionSelector) {
                NavigationStack {
                    SessionSelectorView(
                        coordinator: appCoordinator.eventCoordinator.sessionSelectionCoordinator
                    ) { teamID in
                        Task {
                            await appCoordinator.selectTeam(id: teamID)
                        }
                    }
                }
            }

            Tab("Team", systemImage: "gauge.with.dots.needle.50percent", value: .dashboard) {
                NavigationStack {
                    if let executionCoordinator {
                        ActiveTeamDashboardView(
                            coordinator: executionCoordinator,
                            openStage: { stageID in
                                Task {
                                    await appCoordinator.openStage(id: stageID)
                                }
                            },
                            requestTeamSwitch: {
                                if let targetTeamID = nextSwitchTeamID {
                                    appCoordinator.requestTeamSwitch(to: targetTeamID)
                                }
                            }
                        )
                    } else {
                        EmptyFlowState(title: "Select a team to start inspection.")
                    }
                }
            }

            Tab("Stage", systemImage: "checklist", value: .stageChecklist) {
                NavigationStack {
                    if let executionCoordinator,
                       let stage = executionCoordinator.activeStage {
                        FullStageView(
                            team: executionCoordinator.activeTeam,
                            stage: stage,
                            draftsByTestCaseID: executionCoordinator.draftsByTestCaseID,
                            openTestCase: { testCase in
                                appCoordinator.openTestCase(id: testCase.id)
                            },
                            submitStage: {},
                            openBlockingRoute: { route in
                                if appCoordinator.openTestCase(id: route.testCaseID) {
                                    appCoordinator.openTestStep(id: route.stepID)
                                }
                            }
                        )
                    } else {
                        EmptyFlowState(title: "Open a team stage to inspect.")
                    }
                }
            }

            Tab("Case", systemImage: "list.bullet.rectangle", value: .testCase) {
                NavigationStack {
                    if let executionCoordinator,
                       let stage = executionCoordinator.activeStage,
                       let testCase = executionCoordinator.activeTestCase {
                        TestCaseView(
                            team: executionCoordinator.activeTeam,
                            stage: stage,
                            testCase: InspectionTestCaseViewState(
                                testCase: testCase,
                                draft: executionCoordinator.draft(for: testCase)
                            ),
                            selectedStep: activeStepBinding,
                            selectedScreen: selectedScreenBinding,
                            updateStepDraft: { stepDraft in
                                Task {
                                    await appCoordinator.saveStepDraft(
                                        stepDraft,
                                        testCaseID: testCase.id
                                    )
                                }
                            }
                        )
                    } else {
                        EmptyFlowState(title: "Open a test case from the active stage.")
                    }
                }
            }

            Tab("Step", systemImage: "square.and.pencil", value: .stepDetail) {
                NavigationStack {
                    if let executionCoordinator {
                        StepOverviewView(
                            coordinator: executionCoordinator
                        ) {
                            appCoordinator.selectScreen(.stageChecklist)
                        }
                    } else {
                        EmptyFlowState(title: "Open a test step from a test case.")
                    }
                }
            }
        }
        .tint(Color.fsaePrimary)
        .preferredColorScheme(.light)
        .task {
            appCoordinator.completeMockLogin()
            await loadInspectionContent()
        }
        .sheet(isPresented: teamSwitchConfirmationBinding) {
            if let executionCoordinator,
               executionCoordinator.pendingSwitchTarget != nil {
                TeamSwitchConfirmationView(
                    coordinator: executionCoordinator,
                    cancelSwitch: {
                        appCoordinator.cancelTeamSwitch()
                    },
                    confirmSwitch: {
                        Task {
                            await appCoordinator.confirmTeamSwitch()
                        }
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }

    private var executionCoordinator: InspectionExecutionCoordinator? {
        appCoordinator.eventCoordinator.executionCoordinator
    }

    private var selectedScreenBinding: Binding<ProposedScreen> {
        Binding(
            get: { appCoordinator.selectedScreen },
            set: { appCoordinator.selectScreen($0) }
        )
    }

    private var activeStepBinding: Binding<InspectionTestStep> {
        Binding(
            get: { executionCoordinator?.activeStep ?? MockInspectionData.steps[0] },
            set: { step in
                appCoordinator.openTestStep(id: step.id)
            }
        )
    }

    private var teamSwitchConfirmationBinding: Binding<Bool> {
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

    private var nextSwitchTeamID: Int? {
        guard let activeTeamID = executionCoordinator?.activeTeam.id else {
            return nil
        }

        return appCoordinator.eventCoordinator.sessionSelectionCoordinator.teams
            .first { $0.id != activeTeamID }?
            .id
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

private struct EmptyFlowState: View {
    let title: String

    var body: some View {
        ScreenShell(
            eyebrow: "Inspection Flow",
            title: title,
            subtitle: ""
        ) {
            ContentPanel {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
            }
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
