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
                    } createTeam: { entry in
                        appCoordinator.submitTeamCreation(entry: entry)
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
                            completeSession: {
                                Task {
                                    await appCoordinator.completeActiveSession()
                                }
                            },
                            debugMarkAllPassed: {
                                #if DEBUG
                                Task {
                                    await appCoordinator.markAllTestCasesPassedForDebug()
                                }
                                #endif
                            },
                            debugMarkAllIncomplete: {
                                #if DEBUG
                                Task {
                                    await appCoordinator.markAllTestCasesIncompleteForDebug()
                                }
                                #endif
                            }
                        )
                        .navigationDestination(isPresented: bindings.stagePresentedBinding) {
                            if let stage = executionCoordinator.activeStage {
                                StageNavigationView(
                                    appCoordinator: appCoordinator,
                                    executionCoordinator: executionCoordinator,
                                    stage: stage
                                )
                            }
                        }
                    } else {
                        EmptyFlowState(title: "Select a team to start inspection.")
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
        focusedStage()
            .navigationDestination(for: StageNavigationRoute.self) { route in
                destination(for: route)
            }
    }

    private func focusedStage(testCaseID: String? = nil, stepID: String? = nil) -> some View {
        FullStageView(
            team: executionCoordinator.activeTeam, stage: stage,
            draftsByTestCaseID: executionCoordinator.draftsByTestCaseID,
            saveStepDraft: { draft, caseID in
                await executionCoordinator.saveStepDraft(draft, testCaseID: caseID)
            },
            latestDrafts: { executionCoordinator.draftsByStageID[stage.id] ?? [:] },
            hasUnsavedDraft: executionCoordinator.sessionContext.hasUnsavedDraft,
            hasFailedSave: { (executionCoordinator.failedDraftCaseIDsByStageID[stage.id] ?? []).contains($0) },
            retryFailedSaves: { await executionCoordinator.retryFailedDraftSaves() },
            initialTestCaseID: testCaseID, initialStepID: stepID,
            hasSubmittedStage: executionCoordinator.lastStageSubmission?.stageID == stage.id,
            submitStage: { await appCoordinator.submitActiveStage() }
        )
        .id("\(executionCoordinator.sessionContext.eventID).\(executionCoordinator.sessionContext.sessionID).\(executionCoordinator.activeTeam.id).\(stage.id).\(testCaseID ?? "queue").\(stepID ?? "first")")
    }

    @ViewBuilder
    private func destination(for route: StageNavigationRoute) -> some View {
        switch route {
        case .testCase(let id): focusedStage(testCaseID: id)
        case .testStep(let id, let stepID): focusedStage(testCaseID: id, stepID: stepID)
        }
    }
}
