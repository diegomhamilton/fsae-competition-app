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
                        let expanded = viewModel.isActive(testCase)
                        ExpandableTestCaseRowView(
                            testCase: testCase,
                            session: session,
                            isExpanded: expanded,
                            onTap: {
                                withAnimation(.spring(duration: 0.38, bounce: 0.12)) {
                                    viewModel.activate(testCase)
                                }
                            },
                            onVerdictSet: {
                                if let next = viewModel.nextPending(after: testCase) {
                                    withAnimation(.spring(duration: 0.38, bounce: 0.12)) {
                                        viewModel.activate(next)
                                    }
                                }
                            }
                        )
                        .listRowBackground(expanded ? Color.accentColor.opacity(0.05) : Color.clear)
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
