import SwiftUI

struct FocusedTestDetails: View {
    private enum Strings {
        static let title = "Test details"
        static let instructions = "Instructions"
        static let rules = "Rule references"
        static let done = "Done"
        static let debug = "Debug display"
        static let showType = "Show step type badge"
    }
    let testCase: InspectionTestCaseViewState
    let step: InspectionTestCaseStepViewState
    @Binding var showsTypeBadge: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section(testCase.title) {
                    Text(testCase.code).foregroundStyle(.secondary)
                    Text(step.step.content)
                }
                Section(Strings.rules) {
                    ForEach(testCase.ruleReferences, id: \.self) { rule in
                        Text(rule)
                    }
                }
                if testCase.steps.count > 1 {
                    Section(Strings.instructions) {
                        ForEach(testCase.steps) { item in
                            Text(item.step.content)
                        }
                    }
                }
                #if DEBUG
                Section(Strings.debug) {
                    Toggle(Strings.showType, isOn: $showsTypeBadge)
                        .accessibilityIdentifier("execution.debug-type-toggle")
                }
                #endif
            }
            .navigationTitle(Strings.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.done) { dismiss() }
                        .accessibilityIdentifier("execution.details.done")
                }
            }
        }
        .accessibilityIdentifier("execution.details")
    }
}
