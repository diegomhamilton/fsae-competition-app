//
//  ContentTabsView.swift
//  FSAEInspectionChecklist
//

import SwiftUI

struct ContentTabsView: View {
    @ObservedObject var appCoordinator: AppCoordinator

    var body: some View {
        let bindings = ContentViewBindings(appCoordinator: appCoordinator)

        TabView(selection: bindings.selectedScreenBinding) {
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
                    if let executionCoordinator = bindings.executionCoordinator {
                        ActiveTeamDashboardView(
                            coordinator: executionCoordinator,
                            openStage: { stageID in
                                Task {
                                    await appCoordinator.openStage(id: stageID)
                                }
                            },
                            requestTeamSwitch: {
                                if let targetTeamID = bindings.nextSwitchTeamID {
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
                if let executionCoordinator = bindings.executionCoordinator,
                   let stage = executionCoordinator.activeStage {
                    StageNavigationView(
                        appCoordinator: appCoordinator,
                        executionCoordinator: executionCoordinator,
                        stage: stage
                    )
                } else {
                    NavigationStack {
                        EmptyFlowState(title: "Open a team stage to inspect.")
                    }
                }
            }
        }
    }
}

private struct StageNavigationView: View {
    @ObservedObject var appCoordinator: AppCoordinator
    @ObservedObject var executionCoordinator: InspectionExecutionCoordinator
    let stage: InspectionStage

    var body: some View {
        NavigationStack(path: $executionCoordinator.stageNavigationPath) {
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
            .navigationDestination(for: StageNavigationRoute.self) { route in
                destination(for: route)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: StageNavigationRoute) -> some View {
        switch route {
        case .testCase(let testCaseID):
            if let testCase = testCase(id: testCaseID) {
                TestCaseView(
                    team: executionCoordinator.activeTeam,
                    stage: stage,
                    testCase: InspectionTestCaseViewState(
                        testCase: testCase,
                        draft: executionCoordinator.draft(for: testCase)
                    ),
                    openStepDetail: { step in
                        appCoordinator.openTestStep(id: step.id)
                    },
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
        case .testStep:
            StepOverviewView(
                coordinator: executionCoordinator
            ) {
                appCoordinator.returnToActiveTestCase()
            }
        }
    }

    private func testCase(id testCaseID: String) -> InspectionTestCase? {
        stage.orderedSections
            .flatMap(\.orderedTestCases)
            .first { $0.id == testCaseID }
    }
}
