import SwiftUI

struct TestStepRowView: View {
    let step: TestStep

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: iconName)
                .font(.caption)
                .foregroundStyle(iconColor)
                .frame(width: 16)
                .padding(.top, 2)
            Text(step.content)
                .font(.subheadline)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var iconName: String {
        switch step.type {
        case .requirement:  return "doc.text"
        case .instruction:  return "arrow.right.circle"
        case .precondition: return "exclamationmark.triangle"
        case .note:         return "info.circle"
        }
    }

    private var iconColor: Color {
        switch step.type {
        case .requirement:  return .primary
        case .instruction:  return .accentColor
        case .precondition: return .orange
        case .note:         return .secondary
        }
    }

    private var textColor: Color {
        step.type == .note ? .secondary : .primary
    }

    private var background: Color {
        switch step.type {
        case .precondition: return .orange.opacity(0.08)
        case .note:         return .secondary.opacity(0.06)
        default:            return .clear
        }
    }
}
