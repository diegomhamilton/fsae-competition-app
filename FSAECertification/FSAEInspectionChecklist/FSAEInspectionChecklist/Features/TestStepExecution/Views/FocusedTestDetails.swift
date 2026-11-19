import SwiftUI

struct FocusedTestDetails: View {
    private enum Strings {
        static var title: String { "Test details".inspectionLocalized }
        static var instructions: String { "Instructions".inspectionLocalized }
        static var rules: String { "Rule references".inspectionLocalized }
        static var done: String { "Done".inspectionLocalized }
        static var debug: String { "Debug display".inspectionLocalized }
        static var showType: String { "Show step type badge".inspectionLocalized }
        static var original: String { "Original English".inspectionLocalized }
        static var reference: String { "Translation reference".inspectionLocalized }
        static var translationNote: String { "Portuguese translation of the bundled inspection sheet. Rule references and limits follow the original; this is not an official translated rulebook.".inspectionLocalized }
    }
    #if DEBUG
    @AppStorage(InternalSettingsView.showDebugActionsKey) private var showDebugActions = false
    #endif
    let testCase: InspectionTestCaseViewState
    let step: InspectionTestCaseStepViewState
    @Binding var showsTypeBadge: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section(testCase.title.inspectionLocalized) {
                    Text(testCase.code).foregroundStyle(.secondary)
                    Text(step.step.content.inspectionLocalized)
                }
                Section(Strings.rules) {
                    ForEach(testCase.ruleReferences, id: \.self) { rule in
                        Text(rule)
                    }
                }
                if testCase.steps.count > 1 {
                    Section(Strings.instructions) {
                        ForEach(testCase.steps) { item in
                            Text(item.step.content.inspectionLocalized)
                        }
                    }
                }
                if InspectionLanguage.current == .portuguese {
                    DisclosureGroup(Strings.original) {
                        Text(testCase.title)
                        Text(step.step.content)
                    }
                    .accessibilityIdentifier("execution.details.original-english")
                    Section(Strings.reference) {
                        Link("SAE BRASIL — Inspeção Técnica",
                             destination: URL(string: "https://arquivos.saebrasil.org.br/2024/Formula/Informativo23-GuiadeProcedimentosnaInspecaoTecnicaFSAE-B2024.pdf")!)
                        Text(Strings.translationNote).font(.footnote)
                    }
                }
                #if DEBUG
                if showDebugActions {
                    Section(Strings.debug) {
                        Toggle(Strings.showType, isOn: $showsTypeBadge)
                            .accessibilityIdentifier("execution.debug-type-toggle")
                    }
                }
                #endif
            }
            .navigationTitle(Strings.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.done) { dismiss() }
                        .inspectionButtonStyle()
                        .accessibilityIdentifier("execution.details.done")
                }
                .sharedBackgroundVisibility(.hidden)
            }
        }
        .accessibilityIdentifier("execution.details")
    }
}
