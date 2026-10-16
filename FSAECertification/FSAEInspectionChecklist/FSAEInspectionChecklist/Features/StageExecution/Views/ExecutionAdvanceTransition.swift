import SwiftUI

/// Only confirmed advancement replaces this content identity. Navigation and
/// persistence stay in the coordinator; motion never decides when to advance.
struct ExecutionAdvanceTransition<Content: View>: View {
    let sequence: Int
    @ViewBuilder let content: () -> Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var usesReducedMotion: Bool {
        #if DEBUG
        reduceMotion || ProcessInfo.processInfo.arguments.contains("-inspection-reduce-motion")
        #else
        reduceMotion
        #endif
    }
    var body: some View {
        Group {
            content()
                .id(sequence)
                .transition(usesReducedMotion ? .identity : .asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)))
        }
        .animation(usesReducedMotion ? nil : .easeInOut(duration: 0.22), value: sequence)
    }
}
