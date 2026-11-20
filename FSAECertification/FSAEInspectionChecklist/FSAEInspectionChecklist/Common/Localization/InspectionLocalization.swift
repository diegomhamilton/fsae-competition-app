import Foundation

/// Presentation only: source JSON, IDs, rule references and saved judge input are never translated.
nonisolated enum InspectionLanguage: String, Sendable {
    case portuguese = "pt-BR"
    case english = "en"

    static var current: Self {
        let localization = Bundle.main.preferredLocalizations.first ?? "en"
        return Locale(identifier: localization).language.languageCode?.identifier == "pt" ? .portuguese : .english
    }
}

nonisolated enum InspectionLocalization {
    private static let portugueseBundle: Bundle? = Bundle.main.url(forResource: "pt-BR", withExtension: "lproj")
        .flatMap(Bundle.init(url:))

    static func text(_ source: String, language: InspectionLanguage = .current) -> String {
        guard language == .portuguese else { return source }
        let translated = portugueseBundle?.localizedString(forKey: source, value: source, table: "Localizable") ?? source
        if translated != source { return translated }
        // Decoded steps inherit a generated title; keep the source and stable ID intact.
        if let range = source.range(of: " Step ", options: .backwards),
           let order = Int(source[range.upperBound...]) {
            return "\(text(String(source[..<range.lowerBound]), language: language)) · Etapa \(order)"
        }
        for prefix in ["Completed ", "Saved ", "Started "] where source.hasPrefix(prefix) {
            return String(format: text("\(prefix)%@", language: language), String(source.dropFirst(prefix.count)))
        }
        return source
    }

    static func format(_ source: String, _ arguments: CVarArg...) -> String {
        String(format: text(source), locale: Locale(identifier: InspectionLanguage.current.rawValue), arguments: arguments)
    }
}

extension String {
    nonisolated var inspectionLocalized: String { InspectionLocalization.text(self) }
}
