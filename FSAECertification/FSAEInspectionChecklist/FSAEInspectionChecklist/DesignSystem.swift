import SwiftUI

struct ScreenShell<Content: View>: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(eyebrow.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.fsaePrimary)
                    Text(title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(Color.fsaeText)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.fsaeSecondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)

                content
            }
            .padding(20)
        }
        .background(Color.fsaeBackground)
    }
}

struct StatusPill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.12), in: Capsule())
    }
}

struct ContentPanel<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.fsaeSurface, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.fsaeBorder)
        }
    }
}

struct MetricTile: View {
    let value: String
    let label: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.fsaeText)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.fsaeSecondaryText)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.fsaeSurface, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.fsaeBorder)
        }
    }
}
