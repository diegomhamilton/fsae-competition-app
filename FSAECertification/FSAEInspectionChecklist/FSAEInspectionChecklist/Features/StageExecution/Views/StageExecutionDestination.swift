import SwiftUI

/// Present destinations in the existing app NavigationStack, without nesting another stack.
struct StageExecutionDestination<Content: View>: View {
    let route: StageExecutionRoute
    let coordinator: StageFocusCoordinator
    @ViewBuilder let content: (StageExecutionRoute) -> Content

    var body: some View {
        content(route)
            .navigationDestination(item: Binding(
                get: { coordinator.route(after: route) },
                set: { if $0 == nil { coordinator.popNavigation(after: route) } }
            )) { next in
                Self(route: next, coordinator: coordinator, content: content)
            }
    }
}
