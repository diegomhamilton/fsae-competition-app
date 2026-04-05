import SwiftUI
import SwiftData

@main
struct FSAEInspectionChecklistApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            InspectionTemplate.self,
            InspectionSection.self,
            TestCase.self,
            TestStep.self,
            InspectionSession.self,
            TestCaseResult.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ActiveSessionView()
                .task {
                    let seedService = InspectionSeedService(modelContext: sharedModelContainer.mainContext)
                    do {
                        try seedService.seedIfNeeded()
                    } catch {
                        print("⚠️ Seed failed: \(error)")
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
