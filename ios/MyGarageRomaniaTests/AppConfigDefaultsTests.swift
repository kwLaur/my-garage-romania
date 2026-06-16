import XCTest
@testable import MyGarageRomania

final class AppConfigDefaultsTests: XCTestCase {
    func testProductionBaseURLUsesRailwayHost() {
        XCTAssertEqual(APIBaseURLDefaults.production, "https://my-garage-romania-production.up.railway.app")
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
}
