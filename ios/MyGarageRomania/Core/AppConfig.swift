import Foundation
import SwiftUI

enum APIBaseURLDefaults {
    static let production = "https://my-garage-romania-production.up.railway.app"

    #if DEBUG
    #if targetEnvironment(simulator)
    static let development = "http://localhost:8080"
    #else
    static let development = production
    #endif
    static let current = development
    #else
    static let current = production
    #endif
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: LocalizedStringKey {
        switch self {
        case .system: "theme.system"
        case .light: "theme.light"
        case .dark: "theme.dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english
    case romanian

    var id: String { rawValue }

    var displayName: LocalizedStringKey {
        switch self {
        case .system: "language.system"
        case .english: "language.english"
        case .romanian: "language.romanian"
        }
    }

    var localeIdentifier: String? {
        switch self {
        case .system: nil
        case .english: "en"
        case .romanian: "ro"
        }
    }

    var appleLanguages: [String]? {
        localeIdentifier.map { [$0] }
    }
}

@MainActor
final class AppConfig: ObservableObject {
    @AppStorage("apiBaseURL") var apiBaseURL: String = APIBaseURLDefaults.current {
        didSet { objectWillChange.send() }
    }
    @AppStorage("appTheme") private var appThemeRawValue: String = AppTheme.system.rawValue {
        didSet { objectWillChange.send() }
    }
    @AppStorage("appLanguage") private var appLanguageRawValue: String = AppLanguage.system.rawValue {
        didSet {
            applyLanguagePreference()
            objectWillChange.send()
        }
    }

    var theme: AppTheme {
        get { AppTheme(rawValue: appThemeRawValue) ?? .system }
        set { appThemeRawValue = newValue.rawValue }
    }

    var language: AppLanguage {
        get { AppLanguage(rawValue: appLanguageRawValue) ?? .system }
        set { appLanguageRawValue = newValue.rawValue }
    }

    var normalizedBaseURL: URL {
        let trimmed = apiBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let value = trimmed.isEmpty ? APIBaseURLDefaults.current : trimmed
        return URL(string: value.hasSuffix("/") ? String(value.dropLast()) : value) ?? URL(string: APIBaseURLDefaults.current)!
    }

    func resetBaseURL() {
        apiBaseURL = APIBaseURLDefaults.current
    }

    #if DEBUG
    func useLocalhostBaseURL() {
        apiBaseURL = APIBaseURLDefaults.development
    }
    #endif

    func applyLanguagePreference() {
        if let languages = language.appleLanguages {
            UserDefaults.standard.set(languages, forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
    }
}
