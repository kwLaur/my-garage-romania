import XCTest
@testable import MyGarageRomania

final class AppConfigDefaultsTests: XCTestCase {
    func testProductionBaseURLUsesRailwayHost() {
        XCTAssertEqual(APIBaseURLDefaults.production, "https://my-garage-romania-production.up.railway.app")
    }

    func testRomanianLocalizationHasSameKeysAsEnglish() throws {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let projectRoot = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let englishURL = projectRoot.appendingPathComponent("MyGarageRomania/en.lproj/Localizable.strings")
        let romanianURL = projectRoot.appendingPathComponent("MyGarageRomania/ro.lproj/Localizable.strings")

        let englishKeys = try localizationKeys(from: englishURL)
        let romanianKeys = try localizationKeys(from: romanianURL)

        XCTAssertEqual(romanianKeys.subtracting(englishKeys), [])
        XCTAssertEqual(englishKeys.subtracting(romanianKeys), [])
    }

    #if DEBUG
    func testDebugDefaultBaseURLUsesExpectedHost() {
        XCTAssertEqual(APIBaseURLDefaults.current, APIBaseURLDefaults.development)
        #if targetEnvironment(simulator)
        XCTAssertEqual(APIBaseURLDefaults.current, "http://localhost:8080")
        #else
        XCTAssertEqual(APIBaseURLDefaults.current, "https://my-garage-romania-production.up.railway.app")
        #endif
    }
    #endif

    private func localizationKeys(from url: URL) throws -> Set<String> {
        let content = try String(contentsOf: url, encoding: .utf8)
        let keys = content
            .split(separator: "\n")
            .compactMap { line -> String? in
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmed.hasPrefix("\""), let endIndex = trimmed.dropFirst().firstIndex(of: "\"") else {
                    return nil
                }
                return String(trimmed[trimmed.index(after: trimmed.startIndex)..<endIndex])
            }
        return Set(keys)
    }
}
