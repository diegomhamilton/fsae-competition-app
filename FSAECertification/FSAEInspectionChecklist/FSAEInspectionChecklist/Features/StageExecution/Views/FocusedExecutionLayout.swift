import SwiftUI

/// Uses the available viewport while letting long criteria and keyboards scroll.
struct FocusedExecutionLayout<Header: View, Content: View>: View {
    @Environment(\.dynamicTypeSize) private var textSize
    @ViewBuilder let header: () -> Header
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(spacing: 0) {
            header().fixedSize(horizontal: false, vertical: true).layoutPriority(1).padding(.horizontal, 20)
            GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 24, content: content)
                    .padding(20)
                    .frame(maxWidth: .infinity, minHeight: max(0, geometry.size.height - 40), alignment: .top)
            }
            .scrollDismissesKeyboard(.interactively)
            }
        }
        .background(Color.fsaeBackground)
        #if DEBUG
        .environment(\.dynamicTypeSize, ProcessInfo.processInfo.arguments.contains("-inspection-large-text") ? .accessibility1 : textSize)
        #endif
    }
}
