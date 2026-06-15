import Foundation

struct LoginResponse: Decodable {
    let token: String
    let user: User
}

struct User: Decodable, Hashable {
    let id: UUID?
    let email: String
    let displayName: String?
}

struct Vehicle: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let licensePlate: String
    let vin: String?
    let brand: String?
    let model: String?
    let year: Int?
    let currentKm: Int?
    let fuelProfile: String?
    let imageUrl: String?
    let active: Bool
    let createdAt: String?
    let updatedAt: String?
}

struct VehicleRequest: Codable, Hashable {
    var name: String
    var licensePlate: String
    var vin: String?
    var brand: String?
    var model: String?
    var year: Int?
    var currentKm: Int?
    var fuelProfile: String?
    var imageUrl: String?
    var active: Bool
}

struct VehicleFormDraft: Hashable {
    var name: String
    var licensePlate: String
    var vin: String
    var brand: String
    var model: String
    var year: String
    var currentKm: String
    var fuelProfile: String
    var imageUrl: String
    var active: Bool

    init(vehicle: Vehicle? = nil) {
        name = vehicle?.name ?? ""
        licensePlate = vehicle?.licensePlate ?? ""
        vin = vehicle?.vin ?? ""
        brand = vehicle?.brand ?? ""
        model = vehicle?.model ?? ""
        year = vehicle?.year.map(String.init) ?? ""
        currentKm = vehicle?.currentKm.map(String.init) ?? ""
        fuelProfile = vehicle?.fuelProfile ?? ""
        imageUrl = vehicle?.imageUrl ?? ""
        active = vehicle?.active ?? true
    }

    func makeRequest(currentYear: Int = Calendar.current.component(.year, from: Date())) throws -> VehicleRequest {
        let trimmedName = name.trimmed
        let trimmedLicensePlate = licensePlate.trimmed
        guard !trimmedName.isEmpty else {
            throw VehicleValidationError.nameRequired
        }
        guard !trimmedLicensePlate.isEmpty else {
            throw VehicleValidationError.licensePlateRequired
        }

        let parsedCurrentKm = try optionalNonNegativeInt(currentKm, error: .currentKmInvalid)
        let parsedYear = try optionalNonNegativeInt(year, error: .yearInvalid)
        if let parsedYear, parsedYear < 1886 || parsedYear > currentYear + 1 {
            throw VehicleValidationError.yearInvalid
        }

        return VehicleRequest(
            name: trimmedName,
            licensePlate: trimmedLicensePlate,
            vin: vin.trimmed.nilIfEmpty,
            brand: brand.trimmed.nilIfEmpty,
            model: model.trimmed.nilIfEmpty,
            year: parsedYear,
            currentKm: parsedCurrentKm,
            fuelProfile: fuelProfile.trimmed.nilIfEmpty,
            imageUrl: imageUrl.trimmed.nilIfEmpty,
            active: active
        )
    }

    private func optionalNonNegativeInt(_ value: String, error: VehicleValidationError) throws -> Int? {
        let trimmedValue = value.trimmed
        guard !trimmedValue.isEmpty else { return nil }
        guard let parsed = Int(trimmedValue), parsed >= 0 else {
            throw error
        }
        return parsed
    }
}

enum VehicleValidationError: LocalizedError, Equatable {
    case nameRequired
    case licensePlateRequired
    case currentKmInvalid
    case yearInvalid

    var errorDescription: String? {
        switch self {
        case .nameRequired:
            "Vehicle name is required."
        case .licensePlateRequired:
            "License plate is required."
        case .currentKmInvalid:
            "Current kilometers must be zero or greater."
        case .yearInvalid:
            "Year must be between 1886 and next year."
        }
    }
}

struct Alert: Identifiable, Decodable, Hashable {
    var id: String { "\(vehicleId)-\(category)-\(title)" }
    let severity: String
    let category: String
    let vehicleId: UUID
    let vehicleName: String
    let entityId: UUID
    let title: String
    let detail: String
}

struct LegalDocument: Identifiable, Decodable, Hashable {
    let id: UUID
    let vehicleId: UUID
    let type: String
    let endDate: String?
    let provider: String?
    let daysRemaining: Int?
    let status: String
}

struct MaintenanceItem: Identifiable, Decodable, Hashable {
    let id: UUID
    let vehicleId: UUID
    let type: String
    let lastKm: Int?
    let lastDate: String?
    let intervalKm: Int?
    let intervalDays: Int?
    let cost: Double?
    let kmRemaining: Int?
    let daysRemaining: Int?
    let nextDueKm: Int?
    let nextDueDate: String?
    let status: String
}

struct FuelReceipt: Identifiable, Codable, Hashable {
    let id: UUID?
    let vehicleId: UUID?
    let receiptDate: String
    let stationName: String?
    let fuelType: String
    let quantityLiters: Double?
    let unitPrice: Double?
    let totalAmount: Double?
    let odometerKm: Int?
    let fullTank: Bool
    let source: String?
    let confidenceScore: Double?
    let receiptImageUrl: String?
    let rawOcrText: String?
    let notes: String?
}

struct Expense: Identifiable, Decodable, Hashable {
    let id: UUID
    let vehicleId: UUID
    let title: String
    let amount: Double
    let date: String
    let type: String
}

struct FuelReceiptDraft: Codable, Hashable {
    var receiptDate: String
    var stationName: String
    var fuelType: String
    var quantityLiters: Double?
    var unitPrice: Double?
    var totalAmount: Double?
    var odometerKm: Int?
    var fullTank: Bool
    var source: String
    var confidenceScore: Double?
    var receiptImageUrl: String?
    var rawOcrText: String?
    var notes: String?

    static var emptyManual: FuelReceiptDraft {
        FuelReceiptDraft(
            receiptDate: Date.localDateString(),
            stationName: "",
            fuelType: "DIESEL",
            quantityLiters: nil,
            unitPrice: nil,
            totalAmount: nil,
            odometerKm: nil,
            fullTank: true,
            source: "MANUAL",
            confidenceScore: nil,
            receiptImageUrl: nil,
            rawOcrText: nil,
            notes: nil
        )
    }
}

extension Date {
    static func localDateString() -> String {
        localDateFormatter.string(from: Date())
    }

    private static let localDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }

    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum FuelTypeOption: String, CaseIterable, Identifiable {
    case diesel = "DIESEL"
    case gasoline = "GASOLINE"
    case lpg = "LPG"
    case electric = "ELECTRIC"
    case other = "OTHER"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .diesel: "Diesel"
        case .gasoline: "Gasoline"
        case .lpg: "LPG"
        case .electric: "Electric"
        case .other: "Other"
        }
    }
}
