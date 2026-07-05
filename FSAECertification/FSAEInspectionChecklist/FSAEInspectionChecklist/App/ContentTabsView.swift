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
                NavigationStack {
                    if let executionCoordinator = bindings.executionCoordinator,
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
                    if let executionCoordinator = bindings.executionCoordinator,
                       let stage = executionCoordinator.activeStage,
                       let testCase = executionCoordinator.activeTestCase {
                        TestCaseView(
                            team: executionCoordinator.activeTeam,
                            stage: stage,
                            testCase: InspectionTestCaseViewState(
                                testCase: testCase,
                                draft: executionCoordinator.draft(for: testCase)
                            ),
                            selectedStep: bindings.activeStepBinding,
                            selectedScreen: bindings.selectedScreenBinding,
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
                    if let executionCoordinator = bindings.executionCoordinator {
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
    }
}

