import Foundation

typealias FuelType = FuelTypeOption

struct ParsedReceipt: Equatable {
    var stationName: String?
    var receiptDate: Date?
    var fuelType: FuelType?
    var quantityLiters: Decimal?
    var unitPrice: Decimal?
    var totalAmount: Decimal?
    var odometerKm: Int?
    var rawOcrText: String
    var confidenceScore: Int
    var warnings: [String]

    func draft() -> FuelReceiptDraft {
        FuelReceiptDraft(
            receiptDate: receiptDate.map(Self.backendDateFormatter.string(from:)) ?? Date.localDateString(),
            stationName: stationName ?? "",
            fuelType: fuelType?.rawValue ?? FuelType.other.rawValue,
            quantityLiters: quantityLiters?.doubleValue,
            unitPrice: unitPrice?.doubleValue,
            totalAmount: totalAmount?.doubleValue,
            odometerKm: odometerKm,
            fullTank: true,
            source: "IOS_SCAN",
            confidenceScore: Double(confidenceScore) / 100.0,
            receiptImageUrl: nil,
            rawOcrText: rawOcrText,
            notes: nil
        )
    }

    func dateString() -> String? {
        receiptDate.map(Self.backendDateFormatter.string(from:))
    }

    private static let backendDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

enum ReceiptParser {
    private struct AmountCandidate {
        let value: Decimal
        let explicit: Bool
    }

    static func parse(_ rawText: String) -> ParsedReceipt {
        let text = rawText
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")

        let stationName = parseStation(text)
        let receiptDate = parseDate(text)
        let fuelType = parseFuelType(text)
        let quantityLiters = parseQuantity(text)
        let unitPrice = parseUnitPrice(text)
        let explicitTotal = parseTotal(text)
        let computedTotal = computeTotal(quantity: quantityLiters, unitPrice: unitPrice)
        let totalCandidate = explicitTotal ?? computedTotal.map { AmountCandidate(value: $0, explicit: false) }
        let odometerKm = parseOdometer(text)

        var confidenceScore = 0
        if stationName != nil { confidenceScore += 20 }
        if receiptDate != nil { confidenceScore += 20 }
        if fuelType != nil { confidenceScore += 20 }
        if quantityLiters != nil { confidenceScore += 20 }
        if let totalCandidate {
            confidenceScore += totalCandidate.explicit ? 20 : 5
        }
        if unitPrice != nil { confidenceScore += 10 }
        confidenceScore = min(confidenceScore, 100)

        var warnings: [String] = []
        if receiptDate == nil {
            warnings.append("Receipt date was not detected. Review the default date before saving.")
        }
        if quantityLiters == nil {
            warnings.append("Quantity in liters was not detected.")
        }
        if totalCandidate == nil {
            warnings.append("Total amount was not detected.")
        } else if explicitTotal == nil {
            warnings.append("Total amount was computed from quantity and unit price because no explicit total was detected.")
        }
        if
            let quantityLiters,
            let unitPrice,
            let total = totalCandidate?.value,
            !matchesComputedTotal(quantity: quantityLiters, unitPrice: unitPrice, total: total)
        {
            warnings.append("Total amount does not match quantity multiplied by unit price. Verify the values.")
        }
        if confidenceScore < 70 {
            warnings.append("OCR confidence is low. Review and correct the fields manually.")
        }

        return ParsedReceipt(
            stationName: stationName,
            receiptDate: receiptDate,
            fuelType: fuelType,
            quantityLiters: quantityLiters,
            unitPrice: unitPrice,
            totalAmount: totalCandidate?.value,
            odometerKm: odometerKm,
            rawOcrText: text,
            confidenceScore: confidenceScore,
            warnings: warnings
        )
    }

    private static func parseStation(_ text: String) -> String? {
        let foldedText = folded(text)
        if foldedText.contains("OMV PETROM") || containsWord("OMV", in: foldedText) {
            return "OMV"
        }
        if containsWord("PETROM", in: foldedText) {
            return "Petrom"
        }
        if foldedText.contains("MOL ROMANIA") || containsWord("MOL", in: foldedText) {
            return "MOL"
        }
        if containsWord("ROMPETROL", in: foldedText) {
            return "Rompetrol"
        }
        if containsWord("LUKOIL", in: foldedText) {
            return "Lukoil"
        }
        if containsWord("SOCAR", in: foldedText) {
            return "Socar"
        }
        if containsWord("GAZPROM", in: foldedText) {
            return "Gazprom"
        }
        if containsWord("SHELL", in: foldedText) {
            return "Shell"
        }
        return firstMeaningfulMerchantLine(text)
    }

    private static func parseDate(_ text: String) -> Date? {
        let patterns = [
            #"(?i)(?<!\d)(\d{4})-(\d{1,2})-(\d{1,2})(?:\s+\d{1,2}:\d{2}(?::\d{2})?)?(?!\d)"#,
            #"(?i)(?:DATA|DATA EMITERII|DATĂ|DATA:)?\s*(\d{1,2})[./-](\d{1,2})[./-](\d{4})(?:\s+\d{1,2}:\d{2}(?::\d{2})?)?"#,
            #"(?i)(?<!\d)(?:DATA|DATA EMITERII|DATĂ|DATA:)?\s*(\d{1,2})[./-](\d{1,2})[./-](\d{2})(?:\s+\d{1,2}:\d{2}(?::\d{2})?)?(?!\d)"#
        ]

        for pattern in patterns {
            guard let match = firstMatch(pattern, in: text) else { continue }
            if match.count == 3, pattern.contains(#"(\d{4})-"#) {
                return makeDate(year: match[0], month: match[1], day: match[2])
            }
            if match.count == 3 {
                return makeDate(year: normalizedYear(match[2]), month: match[1], day: match[0])
            }
        }
        return nil
    }

    private static func parseFuelType(_ text: String) -> FuelType? {
        let value = folded(text)
        if value.contains("EURO DIESEL") || value.contains("MOTORINA") || value.contains("DIESEL") {
            return .diesel
        }
        if value.contains("BENZINA") || value.contains("GASOLINE") {
            return .gasoline
        }
        if containsWord("GPL", in: value) || containsWord("LPG", in: value) {
            return .lpg
        }
        if value.contains("EV CHARGE") || value.contains("ELECTRIC") {
            return .electric
        }
        if value.contains("ADBLUE") {
            return .other
        }
        return nil
    }

    private static func parseQuantity(_ text: String) -> Decimal? {
        decimalValue(from: text, patterns: [
            #"(?i)\b(\d{1,4}(?:[,.]\d{1,3})?)\s*L\b"#,
            #"(?i)\b(\d{1,4}(?:[,.]\d{1,3})?)\s*(?:LITRI|LITER|LITERS)\b"#,
            #"(?i)\b(?:LITRI|CANTITATE|CANT\.?|QUANTITY|VOLUM)\D{0,20}(\d{1,4}(?:[,.]\d{1,3})?)\b"#,
            #"(?i)\b(\d{1,4}(?:[,.]\d{1,3})?)\s*(?:L)?\s*x\s*\d{1,2}[,.]\d{2,3}\b"#
        ])
    }

    private static func parseUnitPrice(_ text: String) -> Decimal? {
        decimalValue(from: text, patterns: [
            #"(?i)\b(\d{1,2}(?:[,.]\d{2,3}))\s*(?:RON|LEI)?\s*/\s*L\b"#,
            #"(?i)\b(?:PRET\s*UNITAR|PREȚ\s*UNITAR|PRET/L|PREȚ/L|PRET\s*/\s*L|PREȚ\s*/\s*L|UNIT\s*PRICE)\D{0,16}(\d{1,2}(?:[,.]\d{2,3}))\b"#,
            #"(?i)\b\d{1,4}(?:[,.]\d{1,3})?\s*(?:L)?\s*x\s*(\d{1,2}(?:[,.]\d{2,3}))\b"#
        ])
    }

    private static func parseTotal(_ text: String) -> AmountCandidate? {
        let lines = text.components(separatedBy: .newlines)

        for line in lines where isTotalLine(line) {
            if let value = decimalValue(from: line, patterns: [
                #"(?i)\bTOTAL(?:\s+DE\s+PLATA|\s+PLATA|\s+DE\s+PLATĂ)?\D{0,20}(\d{1,6}(?:[,.]\d{2}))\b"#,
                #"(?i)\b(?:DE\s+PLATA|DE\s+PLATĂ)\D{0,20}(\d{1,6}(?:[,.]\d{2}))\b"#
            ]) {
                return AmountCandidate(value: value, explicit: true)
            }
        }

        for line in lines where !isVatOrSubtotalLine(line) {
            if let value = decimalValue(from: line, patterns: [
                #"(?i)\b(?:CARD|NUMERAR|CASH)\D{0,16}(\d{1,6}(?:[,.]\d{2}))\b"#,
                #"(?i)\bRON\D{0,8}(\d{1,6}(?:[,.]\d{2}))\b"#
            ]) {
                return AmountCandidate(value: value, explicit: true)
            }
        }

        return nil
    }

    private static func parseOdometer(_ text: String) -> Int? {
        guard let value = firstMatch(#"(?i)\b(?:ODOMETRU|ODOMETER|KILOMETRAJ|KM)\D{0,18}(\d{3,7})\s*(?:KM)?\b"#, in: text)?.first else {
            return nil
        }
        return Int(value)
    }

    private static func computeTotal(quantity: Decimal?, unitPrice: Decimal?) -> Decimal? {
        guard let quantity, let unitPrice else { return nil }
        return (quantity * unitPrice).rounded(scale: 2)
    }

    private static func matchesComputedTotal(quantity: Decimal, unitPrice: Decimal, total: Decimal) -> Bool {
        let computed = (quantity * unitPrice).doubleValue
        let actual = total.doubleValue
        return abs(computed - actual) <= 0.05
    }

    private static func isTotalLine(_ line: String) -> Bool {
        let value = folded(line)
        return value.contains("TOTAL") && !isVatOrSubtotalLine(line)
    }

    private static func isVatOrSubtotalLine(_ line: String) -> Bool {
        let value = folded(line)
        return value.contains("TVA") || value.contains("VAT") || value.contains("SUBTOTAL") || value.contains("BAZA")
    }

    private static func firstMeaningfulMerchantLine(_ text: String) -> String? {
        let rejectedTokens = ["DATA", "BON", "TOTAL", "TVA", "CANTITATE", "PRET", "PRODUS", "CARD", "NUMERAR", "FISCAL"]
        for line in text.components(separatedBy: .newlines) {
            let cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let foldedLine = folded(cleaned)
            guard cleaned.count >= 3, cleaned.rangeOfCharacter(from: .letters) != nil else { continue }
            guard !rejectedTokens.contains(where: { foldedLine.contains($0) }) else { continue }
            return cleaned
        }
        return nil
    }

    private static func makeDate(year: String, month: String, day: String) -> Date? {
        guard
            let yearInt = Int(year),
            let monthInt = Int(month),
            let dayInt = Int(day),
            (2000...2100).contains(yearInt),
            (1...12).contains(monthInt),
            (1...31).contains(dayInt)
        else {
            return nil
        }
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = yearInt
        components.month = monthInt
        components.day = dayInt
        return components.date
    }

    private static func normalizedYear(_ value: String) -> String {
        value.count == 2 ? "20\(value)" : value
    }

    private static func decimalValue(from text: String, patterns: [String]) -> Decimal? {
        for pattern in patterns {
            guard let value = firstMatch(pattern, in: text)?.first else { continue }
            if let decimal = Decimal(receiptValue: value) {
                return decimal
            }
        }
        return nil
    }

    private static func firstMatch(_ pattern: String, in text: String) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: range), match.numberOfRanges > 1 else {
            return nil
        }
        return (1..<match.numberOfRanges).compactMap { index in
            guard let range = Range(match.range(at: index), in: text) else { return nil }
            return String(text[range])
        }
    }

    private static func containsWord(_ word: String, in text: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: #"(?<![A-Z0-9])\#(word)(?![A-Z0-9])"#) else {
            return false
        }
        return regex.firstMatch(in: text, range: NSRange(text.startIndex..<text.endIndex, in: text)) != nil
    }

    private static func folded(_ value: String) -> String {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "ro_RO"))
            .uppercased()
    }
}

private extension Decimal {
    init?(receiptValue: String) {
        let normalized = receiptValue
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        self.init(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
    }

    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }

    func rounded(scale: Int) -> Decimal {
        var original = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &original, scale, .plain)
        return rounded
    }
}
