import Foundation

/// A stable destination identity allows review and correction to preserve their own back history.
struct StageExecutionRoute: Hashable, Identifiable {
    let id = UUID()
    let mode: StageFocusCoordinator.Mode
}
