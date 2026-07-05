import Foundation
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct InspectionCoordinatorTests {
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
        #expect(coordinator.selectedScreen == .stepDetail)
        #expect(execution.route == .testStep(stageID: "rain", testCaseID: "rain-rml", stepID: "RT-08"))
        #expect(execution.activeStage?.title == "Rain Test")
        #expect(execution.activeTestCase?.title == "Rain test RML behavior")
        #expect(execution.activeStep?.title == "RML flashing")
    }

    @Test("US-002 execution coordinator rejects unknown stage routes")
    func executionCoordinatorRejectsUnknownStageRoutes() async throws {
        let coordinator = AppCoordinator(teams: teams(), stages: stages())
        coordinator.completeMockLogin()
        #expect(await coordinator.selectTeam(id: 28))
        #expect(await coordinator.openStage(id: "rain"))

        let execution = try #require(coordinator.eventCoordinator.executionCoordinator)
        let originalRoute = execution.route
        let originalStageID = execution.sessionContext.activeStageID

        #expect(!(await coordinator.openStage(id: "unknown-stage")))

        #expect(execution.route == originalRoute)
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
        #expect(execution.route == .teamSwitchConfirmation(currentTeamID: 13, targetTeamID: 28))
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
        #expect(coordinator.selectedScreen == .stepDetail)
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

private func temporaryStoreDirectory() throws -> URL {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("FSAEInspectionChecklistTests")
        .appendingPathComponent(UUID().uuidString)
        .appendingPathComponent("Application Support")
        .appendingPathComponent("FSAEInspectionChecklist")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
}
