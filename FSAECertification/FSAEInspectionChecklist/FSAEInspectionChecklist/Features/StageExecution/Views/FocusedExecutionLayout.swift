import SwiftUI

/// Criteria continue beneath the floating controls; the measured inset makes the final line reachable.
struct FocusedExecutionLayout<Header: View, Content: View, Result: View>: View {
    @Environment(\.dynamicTypeSize) private var textSize
    @State private var resultHeight: CGFloat = 220
    @ViewBuilder let header: () -> Header
    @ViewBuilder let content: () -> Content
    @ViewBuilder let result: () -> Result

    var body: some View {
        VStack(spacing: 0) {
            header().fixedSize(horizontal: false, vertical: true).padding(.horizontal, 24)
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24, content: content)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                        .padding(.bottom, min(resultHeight, geometry.size.height * 0.65))
                }
                .scrollDismissesKeyboard(.interactively)
                .overlay(alignment: .bottom) {
                    ScrollView {
                        result().padding(.horizontal, 24).padding(.top, 8)
                            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { resultHeight = $0 }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .frame(height: min(resultHeight, geometry.size.height * 0.65), alignment: .bottom)
                }
            }
        }
        .background(Color.fsaeBackground)
        #if DEBUG
        .environment(\.dynamicTypeSize, ProcessInfo.processInfo.arguments.contains("-inspection-large-text") ? .accessibility1 : textSize)
        #endif
    }
}
