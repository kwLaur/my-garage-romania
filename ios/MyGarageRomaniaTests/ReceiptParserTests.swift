import XCTest
@testable import MyGarageRomania

final class ReceiptParserTests: XCTestCase {
    func testParsesOMVPetromReceipt() {
        let rawText = """
        OMV Petrom Marketing SRL
        Statia OMV Bucuresti
        DATA: 14.06.2026 12:34
        Produs: Motorina
        Cantitate 42,51 litri
        Pret unitar 7,42 RON/L
        TOTAL DE PLATA 315,42 RON
        """

        let parsed = ReceiptParser.parse(rawText)

        XCTAssertEqual(parsed.dateString(), "2026-06-14")
        XCTAssertEqual(parsed.stationName, "OMV")
        XCTAssertEqual(parsed.fuelType, .diesel)
        assertDecimal(parsed.quantityLiters, equals: 42.51)
        assertDecimal(parsed.unitPrice, equals: 7.42)
        assertDecimal(parsed.totalAmount, equals: 315.42)
        XCTAssertEqual(parsed.rawOcrText, rawText)
        XCTAssertGreaterThanOrEqual(parsed.confidenceScore, 90)
        XCTAssertTrue(parsed.warnings.isEmpty)
    }

    func testParsesMOLReceiptWithSlashDateAndDecimalComma() {
        let rawText = """
        MOL ROMANIA PETROLEUM PRODUCTS SRL
        Data 05/06/2026
        EURO DIESEL
        42,30 L x 7,49 316,83
        CARD 316,83
        """

        let parsed = ReceiptParser.parse(rawText)

        XCTAssertEqual(parsed.dateString(), "2026-06-05")
        XCTAssertEqual(parsed.stationName, "MOL")
        XCTAssertEqual(parsed.fuelType, .diesel)
        assertDecimal(parsed.quantityLiters, equals: 42.30)
        assertDecimal(parsed.unitPrice, equals: 7.49)
        assertDecimal(parsed.totalAmount, equals: 316.83)
        XCTAssertGreaterThanOrEqual(parsed.confidenceScore, 90)
    }

    func testParsesRompetrolGasolineReceipt() {
        let rawText = """
        ROMPETROL DOWNSTREAM SRL
        DATA EMITERII 2026-05-01
        BENZINĂ 95
        31.20 L
        7.15 lei/l
        Total 223.08
        """

        let parsed = ReceiptParser.parse(rawText)

        XCTAssertEqual(parsed.dateString(), "2026-05-01")
        XCTAssertEqual(parsed.stationName, "Rompetrol")
        XCTAssertEqual(parsed.fuelType, .gasoline)
        assertDecimal(parsed.quantityLiters, equals: 31.20)
        assertDecimal(parsed.unitPrice, equals: 7.15)
        assertDecimal(parsed.totalAmount, equals: 223.08)
    }

    func testParsesLukoilSocarStyleGenericReceipt() {
        let rawText = """
        SC LUKOIL ROMANIA SRL
        Bon fiscal
        DATĂ 03-06-26 09:10
        GPL
        LITRI 28,40
        PRET/L 3,29
        TOTAL PLATA 93,44
        KM 154321
        """

        let parsed = ReceiptParser.parse(rawText)

        XCTAssertEqual(parsed.dateString(), "2026-06-03")
        XCTAssertEqual(parsed.stationName, "Lukoil")
        XCTAssertEqual(parsed.fuelType, .lpg)
        assertDecimal(parsed.quantityLiters, equals: 28.40)
        assertDecimal(parsed.unitPrice, equals: 3.29)
        assertDecimal(parsed.totalAmount, equals: 93.44)
        XCTAssertEqual(parsed.odometerKm, 154321)
    }

    func testMapsSocarElectricAndAdBlue() {
        let socarText = """
        SOCAR PETROLEUM SA
        Data: 10.06.2026
        EV CHARGE
        TOTAL 45,00
        """
        let adBlueText = """
        SHELL
        10.06.2026
        ADBLUE
        CANTITATE 8,00
        TOTAL 39,20
        """

        let electric = ReceiptParser.parse(socarText)
        let other = ReceiptParser.parse(adBlueText)

        XCTAssertEqual(electric.stationName, "Socar")
        XCTAssertEqual(electric.fuelType, .electric)
        XCTAssertEqual(other.stationName, "Shell")
        XCTAssertEqual(other.fuelType, .other)
    }

    func testComputesTotalWhenExplicitTotalIsMissing() {
        let rawText = """
        PETROM
        Data 15.06.2026
        Diesel
        42.30 x 7.49 = 316.83
        """

        let parsed = ReceiptParser.parse(rawText)

        XCTAssertEqual(parsed.stationName, "Petrom")
        assertDecimal(parsed.quantityLiters, equals: 42.30)
        assertDecimal(parsed.unitPrice, equals: 7.49)
        assertDecimal(parsed.totalAmount, equals: 316.83)
        XCTAssertTrue(parsed.warnings.contains { $0.contains("computed") })
        XCTAssertLessThan(parsed.confidenceScore, 100)
    }

    func testMissingTotalProducesWarningWhenItCannotBeComputed() {
        let rawText = """
        ROMPETROL
        14.06.2026
        BENZINA
        CANTITATE 20,00
        """

        let parsed = ReceiptParser.parse(rawText)

        XCTAssertNil(parsed.totalAmount)
        XCTAssertTrue(parsed.warnings.contains("Total amount was not detected."))
        XCTAssertLessThan(parsed.confidenceScore, 90)
    }

    func testAvoidsVatSubtotalWhenTotalIsClearer() {
        let rawText = """
        MOL
        Data 14.06.2026
        MOTORINA
        40,00 L x 7,50 300,00
        TVA 19% 47,90
        TOTAL DE PLATA 300,00
        """

        let parsed = ReceiptParser.parse(rawText)

        assertDecimal(parsed.totalAmount, equals: 300.00)
    }

    func testLowConfidenceSampleStillBuildsManualDraft() {
        let rawText = "unrelated faded text"

        let parsed = ReceiptParser.parse(rawText)
        let draft = parsed.draft()

        XCTAssertNil(parsed.receiptDate)
        XCTAssertNil(parsed.fuelType)
        XCTAssertEqual(draft.fuelType, "OTHER")
        XCTAssertEqual(draft.rawOcrText, rawText)
        XCTAssertEqual(draft.source, "IOS_SCAN")
        XCTAssertLessThan(parsed.confidenceScore, 70)
        XCTAssertTrue(parsed.warnings.contains { $0.contains("low") })
    }

    private func assertDecimal(_ value: Decimal?, equals expected: Double, file: StaticString = #filePath, line: UInt = #line) {
        guard let value else {
            XCTFail("Expected decimal \(expected), got nil", file: file, line: line)
            return
        }
        let actual = NSDecimalNumber(decimal: value).doubleValue
        XCTAssertEqual(actual, expected, accuracy: 0.001, file: file, line: line)
    }
}
