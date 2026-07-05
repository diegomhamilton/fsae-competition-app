//
//  InspectionEventStore+AppFactory.swift
//  FSAEInspectionChecklist
//

extension InspectionEventStore {
    static func appStore(
        eventID: String,
        teams: [InspectionTeam],
        stages: [InspectionStage],
        persistenceService: TestCaseJSONPersistenceService = TestCaseJSONPersistenceService()
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
                    id: InspectionEventCoordinator.teamRecordID(team),
                    eventID: eventID,
                    displayName: team.school,
                    carNumber: team.carNumber
                )
            },
            persistenceService: persistenceService
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
            ]
        )
    }
}
