import SwiftUI
import SwiftData

struct InspectionStageView: View {
    @Environment(\.modelContext) private var modelContext
    let template: InspectionTemplate
    let session: InspectionSession
    @State private var viewModel: InspectionStageViewModel

    init(template: InspectionTemplate, session: InspectionSession) {
        self.template = template
        self.session = session
        _viewModel = State(wrappedValue: InspectionStageViewModel(template: template, session: session))
    }

    var body: some View {
        List {
            ForEach(viewModel.sections) { section in
                Section(section.title) {
                    ForEach(viewModel.testCases(in: section)) { testCase in
                        if viewModel.isActive(testCase) {
                            InlineTestCaseView(
                                testCase: testCase,
                                session: session,
                                onVerdictSet: {
                                    if let next = viewModel.nextPending(after: testCase) {
                                        withAnimation(.spring(duration: 0.35)) {
                                            viewModel.activate(next)
                                        }
                                    }
                                }
                            )
                            .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
                            .listRowBackground(Color.accentColor.opacity(0.05))
                        } else {
                            Button {
                                withAnimation(.spring(duration: 0.35)) {
                                    viewModel.activate(testCase)
                                }
                            } label: {
                                TestCaseRowView(
                                    testCase: testCase,
                                    result: viewModel.result(for: testCase)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .navigationTitle(template.title)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: TestCase.self) { testCase in
            TestCaseDetailView(testCase: testCase, session: session)
        }
        .task {
            viewModel.configure(with: TestCaseResultService(modelContext: modelContext))
        }
    }
}
