//
//  InspectionEventStore+AppFactory.swift
//  FSAEInspectionChecklist
//

extension InspectionEventStore {
    static func appStore(
        eventID: String,
        teams: [InspectionTeam] = [],
        stages: [InspectionStage],
        persistenceService: TestCaseJSONPersistenceService = TestCaseJSONPersistenceService(),
        teamCatalogService: LocalTeamCatalogService = LocalTeamCatalogService()
    ) -> InspectionEventStore {
        InspectionEventStore(
            events: [
                InspectionEventDefinition(
                    id: eventID,
                    name: "FSAE Brasil Technical Inspection",
                    stageIDs: stages.map(\.id)
                )
            ],
            teams: teams.map { team in
                InspectionEventTeamRecord(
                    id: InspectionEventStore.localTeamID(carNumber: team.carNumber),
                    eventID: eventID,
                    displayName: team.school,
                    carNumber: team.carNumber
                )
            },
            persistenceService: persistenceService,
            teamCatalogService: teamCatalogService
        )
    }
}

extension InspectionEventUserAccess {
    static func appAccess(
        eventID: String,
        teams: [InspectionTeam],
        userID: String = "local-judge"
    ) -> InspectionEventUserAccess {
        InspectionEventUserAccess(
            userID: userID,
            permittedEventIDs: [eventID],
            permittedTeamIDsByEventID: [
                eventID: Set(teams.map(InspectionEventCoordinator.teamRecordID))
            ],
            permitsAllTeamsForPermittedEvents: teams.isEmpty
        )
    }

    static func localJudgeAccess(
        eventID: String,
        userID: String = "local-judge"
    ) -> InspectionEventUserAccess {
        InspectionEventUserAccess(
            userID: userID,
            permittedEventIDs: [eventID],
            permittedTeamIDsByEventID: [:],
            permitsAllTeamsForPermittedEvents: true
        )
    }
}
