#if DEBUG
import Testing
@testable import FSAEInspectionChecklist

@MainActor
struct InspectionSnapshotLaunchTests {
    @Test("Leaving a preview disables the scenario and its overrides for the rest of the launch")
    func exitDisablesScenarioAndOverrides() {
        let launch = InspectionSnapshotLaunch(arguments: [
            "FSAEInspectionChecklist", "-inspection-snapshot", "save-failure",
            "-inspection-invalid-measurement", "-inspection-large-text"
        ])
        #expect(launch.scenario == .saveFailure)
        #expect(launch.includes("-inspection-invalid-measurement"))
        #expect(launch.includes("-inspection-large-text"))

        launch.exit()

        #expect(launch.scenario == nil)
        #expect(!launch.includes("-inspection-invalid-measurement"))
        #expect(!launch.includes("-inspection-large-text"))
    }

    @Test("An invalid or missing preview scenario keeps overrides out of normal inspections")
    func overridesRequireAValidScenario() {
        for arguments in [
            ["FSAEInspectionChecklist", "-inspection-invalid-measurement"],
            ["FSAEInspectionChecklist", "-inspection-invalid-measurement", "-inspection-snapshot"],
            ["FSAEInspectionChecklist", "-inspection-snapshot", "unknown", "-inspection-invalid-measurement"]
        ] {
            let launch = InspectionSnapshotLaunch(arguments: arguments)
            #expect(launch.scenario == nil)
            #expect(!launch.includes("-inspection-invalid-measurement"))
        }
    }
}
#endif
