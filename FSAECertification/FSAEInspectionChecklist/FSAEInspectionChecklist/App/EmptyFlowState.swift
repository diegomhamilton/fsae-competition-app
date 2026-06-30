//
//  EmptyFlowState.swift
//  FSAEInspectionChecklist
//

import SwiftUI

struct EmptyFlowState: View {
    let title: String

    var body: some View {
        ScreenShell(
            eyebrow: "Inspection Flow",
            title: title,
            subtitle: ""
        ) {
            ContentPanel {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
            }
        }
    }
}

