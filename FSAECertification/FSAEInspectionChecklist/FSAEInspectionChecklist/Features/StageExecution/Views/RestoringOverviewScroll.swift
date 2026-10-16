import SwiftUI

/// Geometry tracks user movement; programmatic restoration must not overwrite it.
struct RestoringOverviewScroll<Content: View>: View {
    let savedOffset: Double
    let rememberOffset: (Double) -> Void
    var revealID: String? = nil
    @ViewBuilder let content: () -> Content
    @State private var position = ScrollPosition()
    @State private var userScrolling = false

    var body: some View {
        ScrollViewReader { proxy in
        ScrollView {
            VStack(alignment: .leading, spacing: 12, content: content)
                .scrollTargetLayout().padding()
        }
        .scrollPosition($position)
        .onScrollPhaseChange { _, phase in
            userScrolling = phase == .interacting || phase == .decelerating
        }
        .onScrollGeometryChange(for: Double.self) { geometry in
            max(0, Double(geometry.contentOffset.y + geometry.contentInsets.top))
        } action: { _, value in
            if userScrolling { rememberOffset(value) }
        }
        .task(id: revealID) {
            await Task.yield()
            if let revealID { proxy.scrollTo(revealID, anchor: .center) }
            else { position.scrollTo(y: savedOffset) }
        }
        }
    }
}
