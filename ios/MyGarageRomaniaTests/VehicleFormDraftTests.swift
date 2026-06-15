import XCTest
@testable import MyGarageRomania

final class VehicleFormDraftTests: XCTestCase {
    func testBuildsVehicleRequestWithTrimmedOptionalFields() throws {
        var draft = VehicleFormDraft()
        draft.name = "  Family Car  "
        draft.licensePlate = "  B123ABC "
        draft.brand = " Dacia "
        draft.model = " Logan "
        draft.year = "2024"
        draft.currentKm = "1200"
        draft.fuelProfile = "DIESEL"
        draft.imageUrl = " "
        draft.active = true

        let request = try draft.makeRequest(currentYear: 2026)

        XCTAssertEqual(request.name, "Family Car")
        XCTAssertEqual(request.licensePlate, "B123ABC")
        XCTAssertEqual(request.brand, "Dacia")
        XCTAssertEqual(request.model, "Logan")
        XCTAssertEqual(request.year, 2024)
        XCTAssertEqual(request.currentKm, 1200)
        XCTAssertEqual(request.fuelProfile, "DIESEL")
        XCTAssertNil(request.imageUrl)
        XCTAssertTrue(request.active)
    }

    func testRequiresNameAndLicensePlate() {
        var draft = VehicleFormDraft()
        draft.licensePlate = "B123ABC"

        XCTAssertThrowsError(try draft.makeRequest(currentYear: 2026)) { error in
            XCTAssertEqual(error as? VehicleValidationError, .nameRequired)
        }

        draft.name = "Family Car"
        draft.licensePlate = ""

        XCTAssertThrowsError(try draft.makeRequest(currentYear: 2026)) { error in
            XCTAssertEqual(error as? VehicleValidationError, .licensePlateRequired)
        }
    }

    func testRejectsInvalidCurrentKmAndYear() {
        var draft = VehicleFormDraft()
        draft.name = "Family Car"
        draft.licensePlate = "B123ABC"
        draft.currentKm = "-1"

        XCTAssertThrowsError(try draft.makeRequest(currentYear: 2026)) { error in
            XCTAssertEqual(error as? VehicleValidationError, .currentKmInvalid)
        }

        draft.currentKm = "100"
        draft.year = "1885"

        XCTAssertThrowsError(try draft.makeRequest(currentYear: 2026)) { error in
            XCTAssertEqual(error as? VehicleValidationError, .yearInvalid)
        }
    }
}
