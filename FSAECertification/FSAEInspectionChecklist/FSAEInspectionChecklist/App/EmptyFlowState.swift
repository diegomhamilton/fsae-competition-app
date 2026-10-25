//
//  EmptyFlowState.swift
//  FSAEInspectionChecklist
//

import SwiftUI

struct EmptyFlowState: View {
    let title: String

    var body: some View {
        ScreenShell(
            title: title
        ) {
            ContentPanel {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.fsaeText)
            }
        }
    }
}

