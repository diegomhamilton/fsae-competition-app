import SwiftUI
import SwiftData

struct TestCaseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let testCase: TestCase
    let session: InspectionSession
    @State private var viewModel: TestCaseDetailViewModel
    @State private var notes = ""
    @State private var isEditingNotes = false

    init(testCase: TestCase, session: InspectionSession) {
        self.testCase = testCase
        self.session = session
        _viewModel = State(wrappedValue: TestCaseDetailViewModel(testCase: testCase, session: session))
    }

    var body: some View {
        List {
            // Badges
            if !testCase.badges.isEmpty {
                Section {
                    HStack(spacing: 8) {
                        ForEach(testCase.badges, id: \.self) { badge in
                            Label(badge, systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.15))
                                .foregroundStyle(Color.orange)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            // Rule reference
            if let ruleRef = testCase.ruleRef {
                Section("Rule Reference") {
                    Text(ruleRef)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Steps
            if !viewModel.sortedSteps.isEmpty {
                Section("Requirements & Steps") {
                    ForEach(viewModel.sortedSteps) { step in
                        TestStepRowView(step: step)
                    }
                }
            }

            // Verdict
            Section("Verdict") {
                verdictPicker
            }

            // Notes
            Section("Inspector Notes") {
                if isEditingNotes {
                    TextField("Add notes…", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .onSubmit { commitNotes() }
                } else {
                    Button(action: { isEditingNotes = true }) {
                        Text(viewModel.result?.inspectorNotes ?? "Tap to add notes…")
                            .foregroundStyle(viewModel.result?.inspectorNotes != nil ? .primary : .secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle(testCase.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isEditingNotes {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { commitNotes() }
                }
            }
        }
        .task {
            viewModel.configure(with: TestCaseResultService(modelContext: modelContext))
            notes = viewModel.result?.inspectorNotes ?? ""
        }
    }

    private var verdictPicker: some View {
        HStack(spacing: 0) {
            ForEach([TestCaseStatus.pass, .fail, .notApplicable], id: \.self) { status in
                let selected = viewModel.result?.status == status
                Button(action: { viewModel.setStatus(status) }) {
                    Text(label(for: status))
                        .font(.subheadline)
                        .fontWeight(selected ? .semibold : .regular)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selected ? color(for: status) : Color.clear)
                        .foregroundStyle(selected ? .white : color(for: status))
                }
                .buttonStyle(.plain)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }

    private func label(for status: TestCaseStatus) -> String {
        switch status {
        case .pass:           return "Pass"
        case .fail:           return "Fail"
        case .notApplicable:  return "N/A"
        case .pending:        return "—"
        }
    }

    private func color(for status: TestCaseStatus) -> Color {
        switch status {
        case .pass:           return .green
        case .fail:           return .red
        case .notApplicable:  return .secondary
        case .pending:        return .secondary
        }
    }

    private func commitNotes() {
        viewModel.setNotes(notes)
        isEditingNotes = false
    }
}
