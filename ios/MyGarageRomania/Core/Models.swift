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

struct LegalDocument: Identifiable, Codable, Hashable {
    let id: UUID
    let vehicleId: UUID
    let type: String
    let startDate: String?
    let endDate: String?
    let provider: String?
    let policyNumber: String?
    let documentUrl: String?
    let cost: Double?
    let source: String?
    let ignored: Bool
    let notes: String?
    let daysRemaining: Int?
    let status: String
    let createdAt: String?
    let updatedAt: String?
}

struct LegalDocumentRequest: Codable, Hashable {
    var type: String
    var startDate: String?
    var endDate: String?
    var provider: String?
    var policyNumber: String?
    var documentUrl: String?
    var cost: Double?
    var source: String?
    var ignored: Bool?
    var notes: String?
}

struct LegalDocumentDraft: Hashable {
    var type: String
    var startDate: String
    var endDate: String
    var provider: String
    var policyNumber: String
    var documentUrl: String
    var cost: String
    var source: String
    var ignored: Bool
    var notes: String

    init(document: LegalDocument? = nil, type: String = LegalDocumentTypeOption.rca.rawValue) {
        self.type = document?.type ?? type
        startDate = document?.startDate ?? Date.localDateString()
        endDate = document?.endDate ?? ""
        provider = document?.provider ?? ""
        policyNumber = document?.policyNumber ?? ""
        documentUrl = document?.documentUrl ?? ""
        cost = document?.cost.map { DomainFormatters.decimalString($0) } ?? ""
        source = document?.source ?? "MANUAL"
        ignored = document?.ignored ?? false
        notes = document?.notes ?? ""
    }

    func makeRequest() throws -> LegalDocumentRequest {
        LegalDocumentRequest(
            type: type,
            startDate: try optionalDateString(startDate),
            endDate: try optionalDateString(endDate),
            provider: provider.trimmed.nilIfEmpty,
            policyNumber: policyNumber.trimmed.nilIfEmpty,
            documentUrl: documentUrl.trimmed.nilIfEmpty,
            cost: try optionalDouble(cost, fieldName: "Cost"),
            source: source.trimmed.nilIfEmpty,
            ignored: ignored,
            notes: notes.trimmed.nilIfEmpty
        )
    }
}

struct MaintenanceItem: Identifiable, Codable, Hashable {
    let id: UUID
    let vehicleId: UUID
    let type: String
    let lastKm: Int?
    let lastDate: String?
    let intervalKm: Int?
    let intervalDays: Int?
    let cost: Double?
    let notes: String?
    let kmRemaining: Int?
    let daysRemaining: Int?
    let nextDueKm: Int?
    let nextDueDate: String?
    let status: String
    let createdAt: String?
    let updatedAt: String?
}

struct MaintenanceRequest: Codable, Hashable {
    var type: String
    var lastKm: Int?
    var lastDate: String?
    var intervalKm: Int?
    var intervalDays: Int?
    var cost: Double?
    var notes: String?
}

struct MaintenanceDraft: Hashable {
    var type: String
    var lastKm: String
    var lastDate: String
    var intervalKm: String
    var intervalDays: String
    var cost: String
    var notes: String

    init(item: MaintenanceItem? = nil) {
        type = item?.type ?? MaintenanceTypeOption.generalService.rawValue
        lastKm = item?.lastKm.map(String.init) ?? ""
        lastDate = item?.lastDate ?? ""
        intervalKm = item?.intervalKm.map(String.init) ?? ""
        intervalDays = item?.intervalDays.map(String.init) ?? ""
        cost = item?.cost.map { DomainFormatters.decimalString($0) } ?? ""
        notes = item?.notes ?? ""
    }

    func makeRequest() throws -> MaintenanceRequest {
        MaintenanceRequest(
            type: type,
            lastKm: try optionalInt(lastKm, fieldName: "Last km"),
            lastDate: try optionalDateString(lastDate),
            intervalKm: try optionalInt(intervalKm, fieldName: "Interval km"),
            intervalDays: try optionalInt(intervalDays, fieldName: "Interval days"),
            cost: try optionalDouble(cost, fieldName: "Cost"),
            notes: notes.trimmed.nilIfEmpty
        )
    }
}

enum NotificationPreferenceEntityType: String, Codable, Hashable {
    case legalDocument = "LEGAL_DOCUMENT"
    case maintenance = "MAINTENANCE"

    var schedulerPrefix: String {
        switch self {
        case .legalDocument:
            "legal-document"
        case .maintenance:
            "maintenance"
        }
    }
}

struct NotificationPreference: Identifiable, Codable, Hashable {
    let id: UUID?
    let vehicleId: UUID
    let entityType: NotificationPreferenceEntityType
    let entityId: UUID
    let enabled: Bool
    let reminderDaysBefore: [Int]
    let notifyOnDueDate: Bool
    let notificationTime: String
    let createdAt: String?
    let updatedAt: String?
}

struct NotificationPreferenceRequest: Codable, Hashable {
    var vehicleId: UUID
    var enabled: Bool
    var reminderDaysBefore: [Int]
    var notifyOnDueDate: Bool
    var notificationTime: String
}

struct NotificationPreferenceDraft: Hashable {
    var enabled: Bool
    var selectedDays: Set<Int>
    var notifyOnDueDate: Bool
    var notificationTime: String

    init(preference: NotificationPreference? = nil) {
        enabled = preference?.enabled ?? false
        selectedDays = Set(preference?.reminderDaysBefore ?? [30, 14, 7, 1])
        notifyOnDueDate = preference?.notifyOnDueDate ?? true
        notificationTime = preference?.notificationTime ?? "09:00"
    }

    func makeRequest(vehicleId: UUID) -> NotificationPreferenceRequest {
        NotificationPreferenceRequest(
            vehicleId: vehicleId,
            enabled: enabled,
            reminderDaysBefore: selectedDays.sorted(by: >),
            notifyOnDueDate: notifyOnDueDate,
            notificationTime: notificationTime
        )
    }
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

struct Expense: Identifiable, Codable, Hashable {
    let id: UUID
    let vehicleId: UUID
    let title: String
    let description: String?
    let amount: Double
    let date: String
    let type: String
    let linkedEntityType: String?
    let linkedEntityId: UUID?
    let createdAt: String?
    let updatedAt: String?
}

struct ExpenseRequest: Codable, Hashable {
    var title: String
    var description: String?
    var amount: Double
    var date: String
    var type: String
    var linkedEntityType: String?
    var linkedEntityId: UUID?
}

struct ExpenseDraft: Hashable {
    var title: String
    var description: String
    var amount: String
    var date: String
    var type: String

    init(expense: Expense? = nil, type: String = ExpenseTypeOption.service.rawValue) {
        title = expense?.title ?? ""
        description = expense?.description ?? ""
        amount = expense.map { DomainFormatters.decimalString($0.amount) } ?? ""
        date = expense?.date ?? Date.localDateString()
        self.type = expense?.type ?? type
    }

    func makeRequest() throws -> ExpenseRequest {
        let trimmedTitle = title.trimmed
        guard !trimmedTitle.isEmpty else {
            throw DomainDraftValidationError.required("Title")
        }

        return ExpenseRequest(
            title: trimmedTitle,
            description: description.trimmed.nilIfEmpty,
            amount: try requiredDouble(amount, fieldName: "Amount"),
            date: try requiredDateString(date, fieldName: "Date"),
            type: type,
            linkedEntityType: nil,
            linkedEntityId: nil
        )
    }
}

struct TireSet: Identifiable, Codable, Hashable {
    let id: UUID
    let vehicleId: UUID
    let tireType: String
    let mountType: String
    let brandModel: String?
    let size: String?
    let dot: String?
    let purchaseDate: String?
    let totalKm: Int?
    let cost: Double?
    let installed: Bool
    let storageLocation: String?
    let pressureFront: Double?
    let pressureRear: Double?
    let notes: String?
    let createdAt: String?
    let updatedAt: String?
}

struct TireSetRequest: Codable, Hashable {
    var tireType: String
    var mountType: String
    var brandModel: String?
    var size: String?
    var dot: String?
    var purchaseDate: String?
    var totalKm: Int?
    var cost: Double?
    var installed: Bool?
    var storageLocation: String?
    var pressureFront: Double?
    var pressureRear: Double?
    var notes: String?
}

struct TireSetDraft: Hashable {
    var tireType: String
    var mountType: String
    var brandModel: String
    var size: String
    var dot: String
    var purchaseDate: String
    var totalKm: String
    var cost: String
    var installed: Bool
    var storageLocation: String
    var pressureFront: String
    var pressureRear: String
    var notes: String

    init(tireSet: TireSet? = nil) {
        tireType = tireSet?.tireType ?? TireTypeOption.allSeason.rawValue
        mountType = tireSet?.mountType ?? TireMountTypeOption.tiresOnly.rawValue
        brandModel = tireSet?.brandModel ?? ""
        size = tireSet?.size ?? ""
        dot = tireSet?.dot ?? ""
        purchaseDate = tireSet?.purchaseDate ?? ""
        totalKm = tireSet?.totalKm.map(String.init) ?? ""
        cost = tireSet?.cost.map { DomainFormatters.decimalString($0) } ?? ""
        installed = tireSet?.installed ?? false
        storageLocation = tireSet?.storageLocation ?? ""
        pressureFront = tireSet?.pressureFront.map { DomainFormatters.decimalString($0) } ?? ""
        pressureRear = tireSet?.pressureRear.map { DomainFormatters.decimalString($0) } ?? ""
        notes = tireSet?.notes ?? ""
    }

    func makeRequest() throws -> TireSetRequest {
        TireSetRequest(
            tireType: tireType,
            mountType: mountType,
            brandModel: brandModel.trimmed.nilIfEmpty,
            size: size.trimmed.nilIfEmpty,
            dot: dot.trimmed.nilIfEmpty,
            purchaseDate: try optionalDateString(purchaseDate),
            totalKm: try optionalInt(totalKm, fieldName: "Total km"),
            cost: try optionalDouble(cost, fieldName: "Cost"),
            installed: installed,
            storageLocation: storageLocation.trimmed.nilIfEmpty,
            pressureFront: try optionalDouble(pressureFront, fieldName: "Front pressure"),
            pressureRear: try optionalDouble(pressureRear, fieldName: "Rear pressure"),
            notes: notes.trimmed.nilIfEmpty
        )
    }
}

struct EquipmentItem: Identifiable, Codable, Hashable {
    let id: UUID
    let vehicleId: UUID
    let type: String
    let name: String?
    let purchaseDate: String?
    let expiryDate: String?
    let present: Bool
    let location: String?
    let cost: Double?
    let notes: String?
    let createdAt: String?
    let updatedAt: String?
}

struct EquipmentRequest: Codable, Hashable {
    var type: String
    var name: String?
    var purchaseDate: String?
    var expiryDate: String?
    var present: Bool?
    var location: String?
    var cost: Double?
    var notes: String?
}

struct EquipmentDraft: Hashable {
    var type: String
    var name: String
    var purchaseDate: String
    var expiryDate: String
    var present: Bool
    var location: String
    var cost: String
    var notes: String

    init(item: EquipmentItem? = nil) {
        type = item?.type ?? EquipmentTypeOption.firstAidKit.rawValue
        name = item?.name ?? ""
        purchaseDate = item?.purchaseDate ?? ""
        expiryDate = item?.expiryDate ?? ""
        present = item?.present ?? true
        location = item?.location ?? ""
        cost = item?.cost.map { DomainFormatters.decimalString($0) } ?? ""
        notes = item?.notes ?? ""
    }

    func makeRequest() throws -> EquipmentRequest {
        EquipmentRequest(
            type: type,
            name: name.trimmed.nilIfEmpty,
            purchaseDate: try optionalDateString(purchaseDate),
            expiryDate: try optionalDateString(expiryDate),
            present: present,
            location: location.trimmed.nilIfEmpty,
            cost: try optionalDouble(cost, fieldName: "Cost"),
            notes: notes.trimmed.nilIfEmpty
        )
    }
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
        formatter.isLenient = false
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

enum LegalDocumentTypeOption: String, CaseIterable, Identifiable {
    case rca = "RCA"
    case casco = "CASCO"
    case itp = "ITP"
    case rovinieta = "ROVINIETA"

    var id: String { rawValue }
    var displayName: String { rawValue == "ROVINIETA" ? "Rovinieta" : rawValue }
}

enum LegalDocumentSourceOption: String, CaseIterable, Identifiable {
    case manual = "MANUAL"
    case cnair = "CNAIR"

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum MaintenanceTypeOption: String, CaseIterable, Identifiable {
    case generalService = "GENERAL_SERVICE"
    case engineOil = "ENGINE_OIL"
    case gearboxOil = "GEARBOX_OIL"
    case timingBelt = "TIMING_BELT"
    case brakeFluid = "BRAKE_FLUID"
    case coolant = "COOLANT"

    var id: String { rawValue }
    var displayName: String { rawValue.domainDisplayName }
}

enum ExpenseTypeOption: String, CaseIterable, Identifiable {
    case service = "SERVICE"
    case fuel = "FUEL"
    case legal = "LEGAL"
    case tire = "TIRE"
    case equipment = "EQUIPMENT"
    case battery = "BATTERY"
    case other = "OTHER"

    var id: String { rawValue }
    var displayName: String { rawValue.domainDisplayName }
}

enum TireTypeOption: String, CaseIterable, Identifiable {
    case summer = "SUMMER"
    case winter = "WINTER"
    case allSeason = "ALL_SEASON"

    var id: String { rawValue }
    var displayName: String { rawValue.domainDisplayName }
}

enum TireMountTypeOption: String, CaseIterable, Identifiable {
    case tiresOnly = "TIRES_ONLY"
    case onRims = "ON_RIMS"

    var id: String { rawValue }
    var displayName: String { rawValue.domainDisplayName }
}

enum EquipmentTypeOption: String, CaseIterable, Identifiable {
    case firstAidKit = "FIRST_AID_KIT"
    case extinguisher = "EXTINGUISHER"
    case reflectiveVest = "REFLECTIVE_VEST"
    case warningTriangle = "WARNING_TRIANGLE"
    case spareWheel = "SPARE_WHEEL"
    case jack = "JACK"
    case compressor = "COMPRESSOR"
    case snowChains = "SNOW_CHAINS"
    case other = "OTHER"

    var id: String { rawValue }
    var displayName: String { rawValue.domainDisplayName }
}

enum DomainDraftValidationError: LocalizedError, Equatable {
    case required(String)
    case invalidNumber(String)
    case invalidDate(String)

    var errorDescription: String? {
        switch self {
        case .required(let field):
            "\(field) is required."
        case .invalidNumber(let field):
            "\(field) must be zero or greater."
        case .invalidDate(let field):
            "\(field) must use YYYY-MM-DD format."
        }
    }
}

enum DomainFormatters {
    static func decimalString(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}

extension String {
    var domainDisplayName: String {
        replacingOccurrences(of: "_", with: " ")
            .lowercased()
            .capitalized
    }
}

private func requiredDouble(_ value: String, fieldName: String) throws -> Double {
    guard let parsed = try optionalDouble(value, fieldName: fieldName) else {
        throw DomainDraftValidationError.required(fieldName)
    }
    return parsed
}

private func optionalDouble(_ value: String, fieldName: String) throws -> Double? {
    let trimmedValue = value.trimmed
    guard !trimmedValue.isEmpty else { return nil }
    let normalized = trimmedValue.replacingOccurrences(of: ",", with: ".")
    guard let parsed = Double(normalized), parsed >= 0 else {
        throw DomainDraftValidationError.invalidNumber(fieldName)
    }
    return parsed
}

private func optionalInt(_ value: String, fieldName: String) throws -> Int? {
    let trimmedValue = value.trimmed
    guard !trimmedValue.isEmpty else { return nil }
    guard let parsed = Int(trimmedValue), parsed >= 0 else {
        throw DomainDraftValidationError.invalidNumber(fieldName)
    }
    return parsed
}

private func requiredDateString(_ value: String, fieldName: String) throws -> String {
    guard let date = try optionalDateString(value, fieldName: fieldName) else {
        throw DomainDraftValidationError.required(fieldName)
    }
    return date
}

private func optionalDateString(_ value: String, fieldName: String = "Date") throws -> String? {
    let trimmedValue = value.trimmed
    guard !trimmedValue.isEmpty else { return nil }
    guard SelfDateFormatter.local.date(from: trimmedValue) != nil else {
        throw DomainDraftValidationError.invalidDate(fieldName)
    }
    return trimmedValue
}

private enum SelfDateFormatter {
    static let local: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
