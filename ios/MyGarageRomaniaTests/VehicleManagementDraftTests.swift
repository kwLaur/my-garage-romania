import XCTest
@testable import MyGarageRomania

final class VehicleManagementDraftTests: XCTestCase {
    func testLegalDocumentDraftBuildsRequestWithTrimmedOptionalFields() throws {
        var draft = LegalDocumentDraft(type: LegalDocumentTypeOption.rca.rawValue)
        draft.startDate = "2026-01-01"
        draft.endDate = "2027-01-01"
        draft.provider = "  Allianz  "
        draft.policyNumber = "  RCA-123  "
        draft.documentUrl = " "
        draft.cost = "450,50"
        draft.source = "MANUAL"
        draft.ignored = false
        draft.notes = "  paid online  "

        let request = try draft.makeRequest()

        XCTAssertEqual(request.type, "RCA")
        XCTAssertEqual(request.startDate, "2026-01-01")
        XCTAssertEqual(request.endDate, "2027-01-01")
        XCTAssertEqual(request.provider, "Allianz")
        XCTAssertEqual(request.policyNumber, "RCA-123")
        XCTAssertNil(request.documentUrl)
        XCTAssertEqual(request.cost, 450.50)
        XCTAssertEqual(request.source, "MANUAL")
        XCTAssertEqual(request.ignored, false)
        XCTAssertEqual(request.notes, "paid online")
    }

    func testExpenseDraftRequiresTitleAmountAndValidDate() {
        var draft = ExpenseDraft()
        draft.title = ""
        draft.amount = "12"
        draft.date = "2026-06-15"

        XCTAssertThrowsError(try draft.makeRequest()) { error in
            XCTAssertEqual(error as? DomainDraftValidationError, .required("Title"))
        }

        draft.title = "Service"
        draft.amount = ""

        XCTAssertThrowsError(try draft.makeRequest()) { error in
            XCTAssertEqual(error as? DomainDraftValidationError, .required("Amount"))
        }

        draft.amount = "100"
        draft.date = "15-06-2026"

        XCTAssertThrowsError(try draft.makeRequest()) { error in
            XCTAssertEqual(error as? DomainDraftValidationError, .invalidDate("Date"))
        }
    }

    func testTireSetDraftBuildsRequestWithOptionalNumericValues() throws {
        var draft = TireSetDraft()
        draft.tireType = TireTypeOption.winter.rawValue
        draft.mountType = TireMountTypeOption.onRims.rawValue
        draft.brandModel = " Michelin Alpin "
        draft.totalKm = "12000"
        draft.pressureFront = "2.3"
        draft.pressureRear = "2,4"
        draft.installed = true

        let request = try draft.makeRequest()

        XCTAssertEqual(request.tireType, "WINTER")
        XCTAssertEqual(request.mountType, "ON_RIMS")
        XCTAssertEqual(request.brandModel, "Michelin Alpin")
        XCTAssertEqual(request.totalKm, 12000)
        XCTAssertEqual(request.pressureFront, 2.3)
        XCTAssertEqual(request.pressureRear, 2.4)
        XCTAssertEqual(request.installed, true)
    }
}
