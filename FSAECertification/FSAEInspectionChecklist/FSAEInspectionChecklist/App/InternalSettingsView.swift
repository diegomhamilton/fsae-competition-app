#if DEBUG
import SwiftUI

struct InternalSettingsView: View {
    enum Strings {
        static let title = "Internal Settings"
        static let debugActions = "Show debug actions"
        static let detail = "Show development actions on the Team screen."
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
