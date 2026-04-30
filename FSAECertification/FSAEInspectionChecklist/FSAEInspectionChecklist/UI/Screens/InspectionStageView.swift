import SwiftUI
import SwiftData

struct InspectionStageView: View {
    @Environment(\.modelContext) private var modelContext
    let template: InspectionTemplate
    let session: InspectionSession
    @State private var viewModel: InspectionStageViewModel
    @State private var scrollTargetID: String?
    @State private var selectedDetailTestCase: TestCase?

    init(template: InspectionTemplate, session: InspectionSession) {
        self.template = template
        self.session = session
        _viewModel = State(wrappedValue: InspectionStageViewModel(template: template, session: session))
    }

    var body: some View {
        ScrollViewReader { proxy in
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
                                        scrollTargetID = testCase.itemId
                                    }
                                },
                                onVerdictSet: {
                                    if let next = viewModel.nextPending(after: testCase) {
                                        withAnimation(.spring(duration: 0.38, bounce: 0.12)) {
                                            viewModel.activate(next)
                                            scrollTargetID = next.itemId
                                        }
                                    }
                                },
                                onInfoTap: {
                                    selectedDetailTestCase = testCase
                                }
                            )
                            .id(testCase.itemId)
                            .listRowBackground(expanded ? Color.accentColor.opacity(0.05) : Color.clear)
                        }
                    }
                }
            }
            .onChange(of: scrollTargetID) { _, target in
                guard let target else { return }
                withAnimation(.easeInOut(duration: 0.25)) {
                    proxy.scrollTo(target, anchor: .center)
                }
            }
        }
        .navigationTitle(template.title)
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            verdictDock
                .padding(.bottom, 24)
        }
        .navigationDestination(for: TestCase.self) { testCase in
            TestCaseDetailView(testCase: testCase, session: session)
        }
        .navigationDestination(item: $selectedDetailTestCase) { testCase in
            TestCaseDetailView(testCase: testCase, session: session)
        }
        .task {
            viewModel.configure(with: TestCaseResultService(modelContext: modelContext))
            if let activeID = viewModel.activeTestCaseID {
                scrollTargetID = activeID
            }
        }
    }

    private var verdictDock: some View {
        HStack(spacing: 10) {
            verdictPill(title: "Pass", status: .pass, tint: .green)
            verdictPill(title: "Fail", status: .fail, tint: .red)
            verdictPill(title: "N/A", status: .notApplicable, tint: .secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.28), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 12, y: 5)
    }

    private func verdictPill(title: String, status: TestCaseStatus, tint: Color) -> some View {
        Button {
            guard viewModel.applyVerdictToActive(status) != nil else { return }
            if let active = viewModel.activeTestCase(), let next = viewModel.nextPending(after: active) {
                withAnimation(.spring(duration: 0.38, bounce: 0.12)) {
                    viewModel.activate(next)
                    scrollTargetID = next.itemId
                }
            }
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .frame(minWidth: 72)
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .background(Color.white.opacity(0.14), in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(viewModel.activeTestCase() == nil)
        .opacity(viewModel.activeTestCase() == nil ? 0.45 : 1)
    }
}
