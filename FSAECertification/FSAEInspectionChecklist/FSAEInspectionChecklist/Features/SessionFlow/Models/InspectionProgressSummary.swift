import Foundation

/// Counts completed inspection steps equally, regardless of their stage size.
struct InspectionProgressSummary: Equatable {
    let completeStepCount: Int
    let totalStepCount: Int

    init(completeStepCount: Int, totalStepCount: Int) {
        self.completeStepCount = completeStepCount
        self.totalStepCount = totalStepCount
    }

    init(stages: [FullStageViewState]) {
        completeStepCount = stages.reduce(0) { $0 + $1.completeStepCount }
        totalStepCount = stages.reduce(0) { $0 + $1.stepCount }
    }

    var fraction: Double {
        guard totalStepCount > 0 else { return 0 }
        return Double(completeStepCount) / Double(totalStepCount)
    }

    var percentageText: String {
        if fraction > 0 && fraction < 0.001 { return "<\(0.001.formatted(.percent.precision(.fractionLength(1))))" }
        return fraction.formatted(.percent.precision(.fractionLength(0...1)))
    }

    var countText: String {
        "\(completeStepCount)/\(totalStepCount) complete"
    }
}
