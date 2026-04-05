import SwiftUI
import SwiftData

struct ActiveSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \InspectionTemplate.displayOrder) private var templates: [InspectionTemplate]
    @Query(sort: \InspectionSession.createdAt, order: .reverse) private var sessions: [InspectionSession]
    @State private var viewModel = ActiveSessionViewModel()
    @State private var isCreatingSession = false
    @State private var teamName = ""
    @State private var vehicleNumber = ""
    @State private var eventYear = Calendar.current.component(.year, from: Date())

    private var activeSession: InspectionSession? { sessions.first }

    var body: some View {
        NavigationStack {
            Group {
                if let session = activeSession {
                    sessionContent(session: session)
                } else {
                    noSessionPlaceholder
                }
            }
            .navigationTitle("FSAE Inspection")
            .toolbar {
                if activeSession != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button("New Session", role: .destructive) {
                                isCreatingSession = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isCreatingSession) {
            newSessionSheet
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            let sessionService = InspectionSessionService(modelContext: modelContext)
            let resultService = TestCaseResultService(modelContext: modelContext)
            viewModel.configure(with: sessionService, resultService: resultService)
        }
    }

    @ViewBuilder
    private func sessionContent(session: InspectionSession) -> some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(session.teamName) — \(session.vehicleNumber)")
                        .font(.headline)
                    Text("Event \(session.eventYear)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            Section("Inspection Stages") {
                ForEach(templates) { template in
                    let (completed, total) = viewModel.progress(for: template, in: session)
                    NavigationLink(value: StageNavigation(template: template, session: session)) {
                        StageCardView(template: template, completed: completed, total: total)
                    }
                }
            }
        }
        .navigationDestination(for: StageNavigation.self) { nav in
            InspectionStageView(template: nav.template, session: nav.session)
        }
    }

    private var noSessionPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "clipboard")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No active session")
                .font(.headline)
            Text("Start a new inspection session to begin.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Start Session") {
                isCreatingSession = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var newSessionSheet: some View {
        NavigationStack {
            Form {
                Section("Team Info") {
                    TextField("Team Name", text: $teamName)
                    TextField("Vehicle Number", text: $vehicleNumber)
                    Stepper("Year: \(eventYear)", value: $eventYear, in: 2020...2099)
                }
            }
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isCreatingSession = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        let t = teamName.trimmingCharacters(in: .whitespaces)
                        let v = vehicleNumber.trimmingCharacters(in: .whitespaces)
                        guard !t.isEmpty, !v.isEmpty else { return }
                        viewModel.createSession(teamName: t, vehicleNumber: v, eventYear: eventYear)
                        isCreatingSession = false
                        teamName = ""
                        vehicleNumber = ""
                    }
                }
            }
        }
    }
}

// Navigation value for stage
struct StageNavigation: Hashable {
    let template: InspectionTemplate
    let session: InspectionSession

    func hash(into hasher: inout Hasher) {
        hasher.combine(template.code)
    }
    static func == (lhs: StageNavigation, rhs: StageNavigation) -> Bool {
        lhs.template.code == rhs.template.code
    }
}
