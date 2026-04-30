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
        case .check:       return "doc.text"
        case .action:      return "arrow.right.circle"
        case .precondition:        return "exclamationmark.triangle"
        case .context:     return "info.circle"
        case .measurement: return "ruler"
        case .evidence:
            switch step.evidenceType {
            case .photo:   return "photo"
            case .video:   return "video"
            case .audio:   return "mic"
            case .pdf:     return "doc.richtext"
            case .text:    return "text.alignleft"
            case .generic: return "paperclip"
            }
        }
    }

    private var iconColor: Color {
        switch step.type {
        case .check:       return .primary
        case .action:      return .accentColor
        case .precondition:        return .orange
        case .context:     return .secondary
        case .measurement: return .teal
        case .evidence:    return .purple
        }
    }

    private var textColor: Color {
        step.type == .context ? .secondary : .primary
    }

    private var background: Color {
        switch step.type {
        case .precondition:        return .orange.opacity(0.08)
        case .context:     return .secondary.opacity(0.06)
        case .measurement: return .teal.opacity(0.08)
        case .evidence:    return .purple.opacity(0.08)
        default:            return .clear
        }
    }
}
