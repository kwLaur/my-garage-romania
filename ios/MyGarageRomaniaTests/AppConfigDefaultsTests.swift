import XCTest
@testable import MyGarageRomania

final class AppConfigDefaultsTests: XCTestCase {
    func testProductionBaseURLUsesRailwayHost() {
        XCTAssertEqual(APIBaseURLDefaults.production, "https://my-garage-romania-production.up.railway.app")
    }

    #if DEBUG
    func testDebugDefaultBaseURLUsesLocalhost() {
        XCTAssertEqual(APIBaseURLDefaults.current, APIBaseURLDefaults.development)
        XCTAssertEqual(APIBaseURLDefaults.current, "http://localhost:8080")
    }
    #endif
}
