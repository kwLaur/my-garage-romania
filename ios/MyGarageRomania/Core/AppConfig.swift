import Foundation
import SwiftUI

@MainActor
final class AppConfig: ObservableObject {
    @AppStorage("apiBaseURL") var apiBaseURL: String = "http://localhost:8080" {
        didSet { objectWillChange.send() }
    }

    var normalizedBaseURL: URL {
        let trimmed = apiBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let value = trimmed.isEmpty ? "http://localhost:8080" : trimmed
        return URL(string: value.hasSuffix("/") ? String(value.dropLast()) : value) ?? URL(string: "http://localhost:8080")!
    }

    func resetBaseURL() {
        apiBaseURL = "http://localhost:8080"
    }
}
