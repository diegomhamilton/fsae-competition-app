import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct InspectionCoordinatorTests {
    @Test("TASK#10.4 production app launch does not seed mock teams")
    func productionAppLaunchDoesNotSeedMockTeams() {
        let coordinator = AppCoordinator(stages: stages())

        #expect(coordinator.eventCoordinator.sessionSelectionCoordinator.teams.isEmpty)
    }

    @Test("TASK#10.4 judge can create a local team and start its session")
    func judgeCanCreateLocalTeamAndStartSession() async throws {
        let rootDirectory = try temporaryStoreDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let eventID = "event-1"
        let store = InspectionEventStore.appStore(
            eventID: eventID,
            teams: [],
            stages: stages(),
            persistenceService: TestCaseJSONPersistenceService(rootDirectory: rootDirectory),
            teamCatalogService: LocalTeamCatalogService(rootDirectory: rootDirectory)
        )
        let coordinator = AppCoordinator(
            eventID: eventID,
            teams: [],
            stages: stages(),
            store: store
        )
        coordinator.completeMockLogin()

        #expect(try await coordinator.createTeam(entry: LocalTeamCatalogEntry(displayName: "UFPE Racing", carNumber: "28")))
        #expect(coordinator.eventCoordinator.sessionSelectionCoordinator.teams.map(\.school) == ["UFPE Racing"])
        #expect(await coordinator.selectTeam(id: 28))

        let execution = try #require(coordinator.eventCoordinator.executionCoordinator)
        #expect(execution.sessionContext.team.school == "UFPE Racing")
        #expect(execution.sessionContext.team.carNumber == "28")
        #expect(execution.sessionContext.activeStageID == "garage")
    }

    @Test("TASK#10.5 relaunch restores active local team session")
    func relaunchRestoresActiveLocalTeamSession() async throws {
        let rootDirectory = try temporaryStoreDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let eventID = "event-1"
        let firstLaunchStore = InspectionEventStore.appStore(
            eventID: eventID,
            teams: [],
            stages: stages(),
            persistenceService: TestCaseJSONPersistenceService(rootDirectory: rootDirectory),
            teamCatalogService: LocalTeamCatalogService(rootDirectory: rootDirectory),
            sessionCatalogService: LocalSessionCatalogService(rootDirectory: rootDirectory)
        )
        let firstLaunch = AppCoordinator(
            eventID: eventID,
            teams: [],
            stages: stages(),
            store: firstLaunchStore
        )
        firstLaunch.completeMockLogin()

        #expect(try await firstLaunch.createTeam(entry: LocalTeamCatalogEntry(displayName: "Solar Hawks", carNumber: "42")))
        #expect(await firstLaunch.selectTeam(id: 42))
        #expect(await firstLaunch.openStage(id: "rain"))
        #expect(await firstLaunch.saveStepDraft(TestStepDraft(stepID: "RT-08", outcome: .pass), testCaseID: "rain-rml"))

        let relaunchedStore = InspectionEventStore.appStore(
            eventID: eventID,
            teams: [],
            stages: stages(),
            persistenceService: TestCaseJSONPersistenceService(rootDirectory: rootDirectory),
            teamCatalogService: LocalTeamCatalogService(rootDirectory: rootDirectory),
            sessionCatalogService: LocalSessionCatalogService(rootDirectory: rootDirectory)
        )
        let relaunched = AppCoordinator(
            eventID: eventID,
            teams: [],
            stages: stages(),
            store: relaunchedStore
        )
        relaunched.completeMockLogin()
        await relaunched.restoreTeamCatalog()

        let restoredTeam = try #require(relaunched.eventCoordinator.sessionSelectionCoordinator.teams.first)
        #expect(restoredTeam.school == "Solar Hawks")
        #expect(restoredTeam.carNumber == "42")
        #expect(restoredTeam.status == .resumed)
        #expect(restoredTeam.currentStage == "Rain Test")
        #expect(await relaunched.selectTeam(id: 42))

        let execution = try #require(relaunched.eventCoordinator.executionCoordinator)
        #expect(execution.sessionContext.team.school == "Solar Hawks")
        #expect(execution.sessionContext.team.carNumber == "42")
        #expect(execution.sessionContext.activeStageID == "rain")
        #expect(execution.sessionContext.endedAt == nil)
    }

    @Test("TASK#10.5 completing active session records endedAt and returns to sessions")
    func completingActiveSessionRecordsEndedAtAndReturnsToSessions() async throws {
        let rootDirectory = try temporaryStoreDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let eventID = "event-1"
        let store = InspectionEventStore.appStore(
            eventID: eventID,
            teams: [teams()[1]],
            stages: stages(),
            persistenceService: TestCaseJSONPersistenceService(rootDirectory: rootDirectory),
            sessionCatalogService: LocalSessionCatalogService(rootDirectory: rootDirectory)
        )
        let coordinator = AppCoordinator(
            eventID: eventID,
            teams: [teams()[1]],
            stages: stages(),
            store: store
        )
        coordinator.completeMockLogin()

        #expect(await coordinator.selectTeam(id: 28))
        let sessionID = try #require(coordinator.eventCoordinator.executionCoordinator?.sessionContext.sessionID)
        let endedAt = Date(timeIntervalSince1970: 1_780_040_000)
        #expect(await coordinator.completeActiveSession(endedAt: endedAt))

        let completedSession = try await store.session(
            eventID: eventID,
            teamID: "car-28",
            sessionID: sessionID,
            access: .appAccess(eventID: eventID, teams: [teams()[1]])
        )
        #expect(completedSession.endedAt == endedAt)
        #expect(coordinator.route == .sessionSelector)
        #expect(coordinator.selectedScreen == .sessionSelector)
        #expect(coordinator.eventCoordinator.executionCoordinator == nil)
    }

    @Test("US-001 login completion opens session selector")
    func loginCompletionOpensSessionSelector() {
        let coordinator = AppCoordinator(teams: teams(), stages: stages())

        coordinator.completeMockLogin()

        #expect(coordinator.route == .sessionSelector)
        #expect(coordinator.selectedScreen == .sessionSelector)
        #expect(coordinator.eventCoordinator.sessionSelectionCoordinator.route == .roster)
    }

    @Test("US-001 start new team session opens Garage Inspection")
    func startNewTeamSessionOpensGarageInspection() async throws {
        let coordinator = AppCoordinator(teams: teams(), stages: stages())
        coordinator.completeMockLogin()

        #expect(await coordinator.selectTeam(id: 28))

        let execution = try #require(coordinator.eventCoordinator.executionCoordinator)
        #expect(coordinator.route == .inspection)
        #expect(coordinator.selectedScreen == .dashboard)
        #expect(coordinator.eventCoordinator.sessionSelectionCoordinator.route == .startNewSession(teamID: 28))
        #expect(execution.sessionContext.team.school == "UFPE Racing")
        #expect(execution.sessionContext.activeStageID == "garage")
        #expect(execution.activeStage?.title == "Garage Inspection")
    }

    @Test("US-001 resume team session restores prior stage")
    func resumeTeamSessionRestoresPriorStage() async throws {
        let coordinator = InspectionEventCoordinator(
            eventID: "event-1",
            teams: teams(),
            stages: stages()
        )

        #expect(await coordinator.startOrResumeSession(for: 13))

        let execution = try #require(coordinator.executionCoordinator)
        #expect(coordinator.sessionSelectionCoordinator.route == .resumeSession(teamID: 13))
        #expect(execution.sessionContext.team.school == "Capibarib-E Racing")
        #expect(execution.sessionContext.activeStageID == "ev")
        #expect(execution.activeStage?.title == "EV Inspection")
    }

    @Test("US-001 blocked team does not open execution flow")
    func blockedTeamDoesNotOpenExecutionFlow() async {
        let coordinator = AppCoordinator(teams: teams(), stages: stages())
        coordinator.completeMockLogin()

        #expect(!((await coordinator.selectTeam(id: 41))))

        #expect(coordinator.route == .sessionSelector)
        #expect(coordinator.selectedScreen == .sessionSelector)
        #expect(coordinator.eventCoordinator.sessionSelectionCoordinator.route == .blocked(teamID: 41))
        #expect(coordinator.eventCoordinator.executionCoordinator == nil)
    }

    @Test("US-002 execution coordinator opens stage case and step routes")
    func executionCoordinatorOpensStageCaseAndStepRoutes() async throws {
        let coordinator = AppCoordinator(teams: teams(), stages: stages())
        coordinator.completeMockLogin()
        #expect(await coordinator.selectTeam(id: 28))

        #expect(await coordinator.openStage(id: "rain"))
        #expect(coordinator.openTestCase(id: "rain-rml"))
        #expect(coordinator.openTestStep(id: "RT-08"))

        let execution = try #require(coordinator.eventCoordinator.executionCoordinator)
        #expect(coordinator.selectedScreen == .stageChecklist)
        #expect(execution.stageNavigationPath == [
            .testCase(testCaseID: "rain-rml"),
            .testStep(testCaseID: "rain-rml", stepID: "RT-08")
        ])
        #expect(execution.activeStage?.title == "Rain Test")
        #expect(execution.activeTestCase?.title == "Rain test RML behavior")
        #expect(execution.activeStep?.title == "RML flashing")
    }

    @Test("TASK#10.3 judge landmarks exclude standalone case and step tabs")
    func guidedNavigationExcludesStandaloneCaseAndStepTabs() {
        #expect(ProposedScreen.topLevelJudgeLandmarks == [.sessionSelector, .dashboard, .stageChecklist])
        #expect(ProposedScreen.topLevelJudgeLandmarks.contains(.testCase) == false)
        #expect(ProposedScreen.topLevelJudgeLandmarks.contains(.stepDetail) == false)
    }

    @Test("TASK#10.3 case and step drill-ins stay inside Stage")
    func caseAndStepDrillInsStayInsideStage() async throws {
        let coordinator = AppCoordinator(teams: teams(), stages: stages())
        coordinator.completeMockLogin()
        #expect(await coordinator.selectTeam(id: 28))

        #expect(await coordinator.openStage(id: "rain"))
        #expect(coordinator.selectedScreen == .stageChecklist)

        #expect(coordinator.openTestCase(id: "rain-rml"))
        var execution = try #require(coordinator.eventCoordinator.executionCoordinator)
        #expect(coordinator.selectedScreen == .stageChecklist)
        #expect(execution.stageNavigationPath == [.testCase(testCaseID: "rain-rml")])

        #expect(coordinator.openTestStep(id: "RT-08"))
        execution = try #require(coordinator.eventCoordinator.executionCoordinator)
        #expect(coordinator.selectedScreen == .stageChecklist)
        #expect(execution.stageNavigationPath == [
            .testCase(testCaseID: "rain-rml"),
            .testStep(testCaseID: "rain-rml", stepID: "RT-08")
        ])

        coordinator.returnToActiveTestCase()
        #expect(coordinator.selectedScreen == .stageChecklist)
        #expect(execution.stageNavigationPath == [.testCase(testCaseID: "rain-rml")])

        coordinator.returnToActiveStage()
        #expect(coordinator.selectedScreen == .stageChecklist)
        #expect(execution.stageNavigationPath == [])
    }

    @Test("US-002 execution coordinator rejects unknown stage routes")
    func executionCoordinatorRejectsUnknownStageRoutes() async throws {
        let coordinator = AppCoordinator(teams: teams(), stages: stages())
        coordinator.completeMockLogin()
        #expect(await coordinator.selectTeam(id: 28))
        #expect(await coordinator.openStage(id: "rain"))

        let execution = try #require(coordinator.eventCoordinator.executionCoordinator)
        let originalPath = execution.stageNavigationPath
        let originalStageID = execution.sessionContext.activeStageID

        #expect(!(await coordinator.openStage(id: "unknown-stage")))

        #expect(execution.stageNavigationPath == originalPath)
        #expect(execution.sessionContext.activeStageID == originalStageID)
        #expect(execution.activeStage?.id == "rain")
    }

    @Test("US-006 team switch routes through confirmation")
    func teamSwitchRoutesThroughConfirmation() async throws {
        let coordinator = AppCoordinator(teams: teams(), stages: stages())
        coordinator.completeMockLogin()
        #expect(await coordinator.selectTeam(id: 13))

        let execution = try #require(coordinator.eventCoordinator.executionCoordinator)
        execution.markUnsavedDraft(true)

        #expect(coordinator.requestTeamSwitch(to: 28))
        #expect(execution.stageNavigationPath == [])
        #expect(execution.pendingSwitchTarget?.id == 28)

        #expect(await coordinator.confirmTeamSwitch())

        let switchedExecution = try #require(coordinator.eventCoordinator.executionCoordinator)
        #expect(coordinator.selectedScreen == .dashboard)
        #expect(switchedExecution.sessionContext.team.id == 28)
        #expect(switchedExecution.sessionContext.activeStageID == "garage")
    }

    @Test("TASK#7.8 coordinator selected state feeds backed views")
    func coordinatorSelectedStateFeedsBackedViews() async throws {
        let coordinator = AppCoordinator(teams: teams(), stages: stages())
        coordinator.completeMockLogin()
        #expect(await coordinator.selectTeam(id: 28))

        #expect(await coordinator.openStage(id: "rain"))
        let execution = try #require(coordinator.eventCoordinator.executionCoordinator)
        let stage = try #require(execution.activeStage)
        let stageState = FullStageViewState(stage: stage)

        #expect(stageState.stageID == "rain")
        #expect(stageState.stageTitle == "Rain Test")

        #expect(coordinator.openTestCase(id: "rain-rml"))
        let testCase = try #require(execution.activeTestCase)
        let testCaseState = InspectionTestCaseViewState(testCase: testCase)

        #expect(testCaseState.id == "rain-rml")
        #expect(testCaseState.steps.map(\.id) == ["RT-07", "RT-08"])

        #expect(coordinator.openTestStep(id: "RT-08"))
        #expect(execution.activeStep?.id == "RT-08")
        #expect(coordinator.selectedScreen == .stageChecklist)
    }

    @Test("TASK#7.1 store-backed coordinator saves and restores draft values")
    func storeBackedCoordinatorSavesAndRestoresDraftValues() async throws {
        let rootDirectory = try temporaryStoreDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let eventID = "event-1"
        let store = InspectionEventStore.appStore(
            eventID: eventID,
            teams: teams(),
            stages: stages(),
            persistenceService: TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
        )
        let firstLaunch = AppCoordinator(
            eventID: eventID,
            teams: teams(),
            stages: stages(),
            store: store
        )
        firstLaunch.completeMockLogin()

        #expect(await firstLaunch.selectTeam(id: 28))
        #expect(await firstLaunch.openStage(id: "rain"))
        #expect(firstLaunch.openTestCase(id: "rain-rml"))

        let evidence = EvidenceAttachmentMetadata(
            id: "rml-restored-photo",
            displayName: "RML restored photo",
            mediaType: .photo,
            source: .mockAttachment,
            createdAt: Date(timeIntervalSince1970: 1_780_002_000)
        )
        let stepDraft = TestStepDraft(
            stepID: "RT-08",
            outcome: .pass,
            notes: "RML visible after TS activation.",
            evidenceAttachments: [evidence]
        )

        #expect(await firstLaunch.saveStepDraft(stepDraft, testCaseID: "rain-rml"))

        let relaunched = AppCoordinator(
            eventID: eventID,
            teams: teams(),
            stages: stages(),
            store: store
        )
        relaunched.completeMockLogin()

        #expect(await relaunched.selectTeam(id: 28))
        #expect(await relaunched.openStage(id: "rain"))

        let execution = try #require(relaunched.eventCoordinator.executionCoordinator)
        let restoredDraft = try #require(execution.draftsByTestCaseID["rain-rml"])
        let restoredStep = try #require(restoredDraft.stepDraft(stepID: "RT-08")?.draft)

        #expect(restoredStep.outcome == .pass)
        #expect(restoredStep.notes == "RML visible after TS activation.")
        #expect(restoredStep.evidenceAttachments == [evidence])

        let testCase = try #require(execution.activeStage?.orderedSections.flatMap(\.orderedTestCases).first { $0.id == "rain-rml" })
        let viewState = InspectionTestCaseViewState(testCase: testCase, draft: restoredDraft)
        #expect(viewState.steps.first { $0.id == "RT-08" }?.notes == "RML visible after TS activation.")

        #expect(await relaunched.selectTeam(id: 13))
        #expect(await relaunched.openStage(id: "rain"))
        let switchedExecution = try #require(relaunched.eventCoordinator.executionCoordinator)
        #expect(switchedExecution.draftsByTestCaseID["rain-rml"] == nil)
    }

    @Test("Issue #56 dashboard stage row ignores static complete metadata when draft is unanswered")
    func issue56DashboardStageRowUsesDraftBackedStatusForUnansweredStage() {
        let stage = staticCompleteStageWithRequiredStep()

        let row = ActiveTeamStageRowState(stage: stage)

        #expect(row.status == .blocked)
        #expect(row.statusText == "1 blocker")
        #expect(row.completedStepCount == 0)
        #expect(row.totalStepCount == 1)
        #expect(row.blockerCount == 1)
        #expect(row.progressFraction == 0)
    }

    @Test("Issue #56 dashboard stage row marks complete only when draft validation passes")
    func issue56DashboardStageRowCompletesOnlyWithPassingDraft() {
        let stage = staticCompleteStageWithRequiredStep()
        let testCase = stage.orderedSections[0].orderedTestCases[0]
        let draft = TestCaseDraft(
            testCase: testCase,
            stepDrafts: [TestStepDraft(stepID: "STATIC-STEP", outcome: .pass)]
        )

        let row = ActiveTeamStageRowState(
            stage: stage,
            draftsByTestCaseID: [testCase.id: draft]
        )

        #expect(row.status == .complete)
        #expect(row.statusText == "Complete")
        #expect(row.completedStepCount == 1)
        #expect(row.totalStepCount == 1)
        #expect(row.blockerCount == 0)
        #expect(row.progressFraction == 1)
    }

    @Test("TASK#10.1 stage switching preserves other stage draft progress")
    func stageSwitchingPreservesOtherStageDraftProgress() async throws {
        let rootDirectory = try temporaryStoreDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }
        let eventID = "event-1"
        let stages = stageSwitchStages()
        let coordinator = AppCoordinator(
            eventID: eventID,
            teams: teams(),
            stages: stages,
            store: InspectionEventStore.appStore(
                eventID: eventID,
                teams: teams(),
                stages: stages,
                persistenceService: TestCaseJSONPersistenceService(rootDirectory: rootDirectory)
            )
        )
        coordinator.completeMockLogin()

        #expect(await coordinator.selectTeam(id: 28))
        #expect(await coordinator.openStage(id: "ev"))
        #expect(await coordinator.saveStepDraft(TestStepDraft(stepID: "EV-01", outcome: .pass), testCaseID: "ev-main"))

        var execution = try #require(coordinator.eventCoordinator.executionCoordinator)
        var evStageState = try #require(execution.stages.first { $0.stageID == "ev" })
        #expect(evStageState.progressFraction == 1)

        #expect(await coordinator.openStage(id: "chassis"))
        execution = try #require(coordinator.eventCoordinator.executionCoordinator)
        evStageState = try #require(execution.stages.first { $0.stageID == "ev" })
        var chassisStageState = try #require(execution.stages.first { $0.stageID == "chassis" })
        #expect(evStageState.progressFraction == 1)
        #expect(chassisStageState.progressFraction == 0)

        #expect(await coordinator.saveStepDraft(TestStepDraft(stepID: "CH-01", outcome: .pass), testCaseID: "chassis-main"))
        execution = try #require(coordinator.eventCoordinator.executionCoordinator)
        evStageState = try #require(execution.stages.first { $0.stageID == "ev" })
        chassisStageState = try #require(execution.stages.first { $0.stageID == "chassis" })

        #expect(evStageState.progressFraction == 1)
        #expect(chassisStageState.progressFraction == 1)
    }
}

private func teams() -> [InspectionTeam] {
    [
        InspectionTeam(
            id: 13,
            school: "Capibarib-E Racing",
            carNumber: "13",
            status: .resumed,
            currentStage: "EV Inspection",
            lastSaved: "Saved 2 min ago"
        ),
        InspectionTeam(
            id: 28,
            school: "UFPE Racing",
            carNumber: "28",
            status: .ready,
            currentStage: "Garage Inspection",
            lastSaved: "Not started"
        ),
        InspectionTeam(
            id: 41,
            school: "UFPE Electric",
            carNumber: "41",
            status: .blocked,
            currentStage: "Rain Test",
            lastSaved: "Needs evidence"
        )
    ]
}

private func stages() -> [InspectionStage] {
    [
        InspectionStage(
            id: "garage",
            code: "01",
            title: "Garage Inspection",
            displayOrder: 1,
            subtitle: "Driver equipment",
            sections: []
        ),
        InspectionStage(
            id: "ev",
            code: "04",
            title: "EV Inspection",
            displayOrder: 4,
            subtitle: "Accumulator and shutdown checks",
            sections: []
        ),
        InspectionStage(
            id: "rain",
            code: "06",
            title: "Rain Test",
            displayOrder: 6,
            subtitle: "IMD validation",
            sections: [
                InspectionSection(
                    id: "rain.primary",
                    title: "Rain Test Checks",
                    displayOrder: 1,
                    testCases: [
                        InspectionTestCase(
                            id: "rain-rml",
                            code: "RAIN-RML",
                            displayOrder: 1,
                            title: "Rain test RML behavior",
                            ruleReferences: ["RAIN.1"],
                            steps: [
                                inspectionStep(
                                    id: "RT-07",
                                    title: "Activate TS",
                                    type: .action
                                ),
                                inspectionStep(
                                    id: "RT-08",
                                    title: "RML flashing",
                                    requiresEvidence: true
                                )
                            ]
                        )
                    ]
                )
            ]
        )
    ]
}

private func stageSwitchStages() -> [InspectionStage] {
    [
        InspectionStage(
            id: "chassis",
            code: "03",
            title: "Chassis Inspection",
            displayOrder: 3,
            subtitle: "Structure and suspension checks",
            sections: [
                InspectionSection(
                    id: "chassis.primary",
                    title: "Chassis Checks",
                    displayOrder: 1,
                    testCases: [
                        InspectionTestCase(
                            id: "chassis-main",
                            code: "CH-MAIN",
                            displayOrder: 1,
                            title: "Chassis main checks",
                            ruleReferences: ["T.1"],
                            steps: [
                                inspectionStep(id: "CH-01", title: "Frame structure")
                            ]
                        )
                    ]
                )
            ]
        ),
        InspectionStage(
            id: "ev",
            code: "04",
            title: "EV Inspection",
            displayOrder: 4,
            subtitle: "Accumulator and shutdown checks",
            sections: [
                InspectionSection(
                    id: "ev.primary",
                    title: "EV Checks",
                    displayOrder: 1,
                    testCases: [
                        InspectionTestCase(
                            id: "ev-main",
                            code: "EV-MAIN",
                            displayOrder: 1,
                            title: "EV main checks",
                            ruleReferences: ["EV.1"],
                            steps: [
                                inspectionStep(id: "EV-01", title: "Accumulator container")
                            ]
                        )
                    ]
                )
            ]
        )
    ]
}

private func inspectionStep(
    id: String,
    title: String,
    type: InspectionTestStepType = .check,
    requiresEvidence: Bool = false
) -> InspectionTestStep {
    InspectionTestStep(
        id: id,
        code: id,
        ruleReference: "EV.6.1",
        title: title,
        type: type,
        content: "Test content for \(title).",
        requiredOutcome: true,
        requiresEvidence: requiresEvidence
    )
}

private func staticCompleteStageWithRequiredStep() -> InspectionStage {
    InspectionStage(
        id: "static-complete",
        code: "static-complete",
        title: "Static Complete",
        displayOrder: 1,
        subtitle: "Regression fixture",
        progress: 1,
        requiredOpenItems: 0,
        sections: [
            InspectionSection(
                id: "static-complete.section",
                title: "Static Complete Section",
                displayOrder: 1,
                testCases: [
                    InspectionTestCase(
                        id: "static-case",
                        code: "STATIC",
                        displayOrder: 1,
                        title: "Static case",
                        steps: [
                            inspectionStep(
                                id: "STATIC-STEP",
                                title: "Required answer"
                            )
                        ]
                    )
                ]
            )
        ]
    )
}

private func temporaryStoreDirectory() throws -> URL {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("FSAEInspectionChecklistTests")
        .appendingPathComponent(UUID().uuidString)
        .appendingPathComponent("Application Support")
        .appendingPathComponent("FSAEInspectionChecklist")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
}
