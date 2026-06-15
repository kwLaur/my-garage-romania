import Foundation
import SwiftUI

enum APIBaseURLDefaults {
    static let production = "https://my-garage-romania-production.up.railway.app"

    #if DEBUG
    static let development = "https://my-garage-romania-production.up.railway.app"
    static let current = development
    #else
    static let current = production
    #endif
}

@MainActor
final class AppConfig: ObservableObject {
    @AppStorage("apiBaseURL") var apiBaseURL: String = APIBaseURLDefaults.current {
        didSet { objectWillChange.send() }
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
}
