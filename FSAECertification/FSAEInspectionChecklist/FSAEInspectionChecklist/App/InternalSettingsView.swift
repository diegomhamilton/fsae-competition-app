#if DEBUG
import SwiftUI

struct InternalSettingsView: View {
    enum Strings {
        static var title: String { "Internal Settings".inspectionLocalized }
        static var debugActions: String { "Show debug actions".inspectionLocalized }
        static var detail: String { "Show development actions on the Team screen and debug display options in test details.".inspectionLocalized }
    }

    static let showDebugActionsKey = "internalSettings.showDebugActions"
    @AppStorage(Self.showDebugActionsKey) private var showDebugActions = false

    var body: some View {
        Form {
            Section {
                Toggle(Strings.debugActions, isOn: $showDebugActions)
                    .accessibilityIdentifier("internal-settings.show-debug-actions")
            } footer: {
                Text(Strings.detail)
            }
        }
        .navigationTitle(Strings.title)
        .accessibilityIdentifier("internal-settings")
    }
}
#endif
