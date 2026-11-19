import SwiftUI

struct FocusedMeasurementInput: View {
    let form: FocusedResultForm
    let focusedField: FocusState<FocusedResultField?>.Binding
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                TextField(FocusedResultStrings.measurement,
                    text: Binding(get: { form.draft.measurementInput }, set: form.updateMeasurement))
                    .font(.largeTitle.bold()).minimumScaleFactor(0.7)
                    .measurementKeyboard().focused(focusedField, equals: .measurement)
                    .accessibilityIdentifier(InspectionAccessibilityIdentifier.measurementField(stepID: form.step.id).rawValue)
                Text(form.step.measurementRange?.unit.symbol ?? "").font(.title.bold())
            }
            if !form.draft.measurementInput.isEmpty {
                ForEach(form.validationIssues.filter { $0.code == .invalidMeasurement }) { issue in
                    Text(issue.localizedMessage).font(.callout).foregroundStyle(Color.fsaeRed)
                        .accessibilityIdentifier("execution.measurement.error")
                }
            }

        }
        .padding(16).background(Color.fsaeBackground, in: .rect(cornerRadius: 20))
    }
}
