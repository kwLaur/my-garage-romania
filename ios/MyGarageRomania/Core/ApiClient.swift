import Foundation
import UIKit

enum ApiError: LocalizedError {
    case invalidURL
    case missingToken
    case emptyResponse
    case requestFailed(Int, String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid API URL."
        case .missingToken:
            "You are not logged in."
        case .emptyResponse:
            "The server returned an empty response."
        case .requestFailed(let status, let message):
            "\(message) (\(status))"
        }
    }
}

enum ConnectionTestResult: Equatable {
    case connected
    case unauthorizedReachable
    case cannotReachServer
    case invalidURL

    var title: String {
        switch self {
        case .connected:
            "Connected"
        case .unauthorizedReachable:
            "Unauthorized but server reachable"
        case .cannotReachServer:
            "Cannot reach server"
        case .invalidURL:
            "Invalid URL"
        }
    }
}

struct HealthResponse: Decodable {
    let status: String
    let app: String
}

@MainActor
final class ApiClient {
    private let config: AppConfig
    private let keychain: KeychainStore
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(config: AppConfig, keychain: KeychainStore, session: URLSession = .shared) {
        self.config = config
        self.keychain = keychain
        self.session = session
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        let body = ["email": email, "password": password]
        let data = try encoder.encode(body)
        return try await request("/api/auth/login", method: "POST", body: data, requiresAuth: false)
    }

    func getVehicles() async throws -> [Vehicle] {
        try await request("/api/vehicles")
    }

    func fetchVehicles() async throws -> [Vehicle] {
        try await getVehicles()
    }

    func fetchVehicle(id: UUID) async throws -> Vehicle {
        try await request("/api/vehicles/\(id.uuidString)")
    }

    func createVehicle(_ request: VehicleRequest) async throws -> Vehicle {
        let data = try encoder.encode(request)
        return try await self.request("/api/vehicles", method: "POST", body: data)
    }

    func updateVehicle(id: UUID, request: VehicleRequest) async throws -> Vehicle {
        let data = try encoder.encode(request)
        return try await self.request("/api/vehicles/\(id.uuidString)", method: "PUT", body: data)
    }

    func fetchAlerts() async throws -> [Alert] {
        try await request("/api/dashboard/alerts")
    }

    func fetchLegalDocuments(vehicleId: UUID) async throws -> [LegalDocument] {
        try await request("/api/vehicles/\(vehicleId.uuidString)/legal-documents")
    }

    func createLegalDocument(vehicleId: UUID, request: LegalDocumentRequest) async throws -> LegalDocument {
        let data = try encoder.encode(request)
        return try await self.request("/api/vehicles/\(vehicleId.uuidString)/legal-documents", method: "POST", body: data)
    }

    func updateLegalDocument(id: UUID, request: LegalDocumentRequest) async throws -> LegalDocument {
        let data = try encoder.encode(request)
        return try await self.request("/api/legal-documents/\(id.uuidString)", method: "PUT", body: data)
    }

    func deleteLegalDocument(id: UUID) async throws {
        try await requestNoContent("/api/legal-documents/\(id.uuidString)", method: "DELETE")
    }

    func fetchMaintenance(vehicleId: UUID) async throws -> [MaintenanceItem] {
        try await request("/api/vehicles/\(vehicleId.uuidString)/maintenance")
    }

    func createMaintenance(vehicleId: UUID, request: MaintenanceRequest) async throws -> MaintenanceItem {
        let data = try encoder.encode(request)
        return try await self.request("/api/vehicles/\(vehicleId.uuidString)/maintenance", method: "POST", body: data)
    }

    func updateMaintenance(id: UUID, request: MaintenanceRequest) async throws -> MaintenanceItem {
        let data = try encoder.encode(request)
        return try await self.request("/api/maintenance/\(id.uuidString)", method: "PUT", body: data)
    }

    func deleteMaintenance(id: UUID) async throws {
        try await requestNoContent("/api/maintenance/\(id.uuidString)", method: "DELETE")
    }

    func fetchNotificationPreferences(vehicleId: UUID) async throws -> [NotificationPreference] {
        try await request("/api/vehicles/\(vehicleId.uuidString)/notification-preferences")
    }

    func fetchNotificationPreference(entityType: NotificationPreferenceEntityType, entityId: UUID) async throws -> NotificationPreference? {
        do {
            return try await request("/api/notification-preferences/\(entityType.rawValue)/\(entityId.uuidString)")
        } catch ApiError.requestFailed(let status, _) where status == 404 {
            return nil
        }
    }

    func saveNotificationPreference(entityType: NotificationPreferenceEntityType, entityId: UUID, request: NotificationPreferenceRequest) async throws -> NotificationPreference {
        let data = try encoder.encode(request)
        return try await self.request("/api/notification-preferences/\(entityType.rawValue)/\(entityId.uuidString)", method: "PUT", body: data)
    }

    func deleteNotificationPreference(entityType: NotificationPreferenceEntityType, entityId: UUID) async throws {
        try await requestNoContent("/api/notification-preferences/\(entityType.rawValue)/\(entityId.uuidString)", method: "DELETE")
    }

    func fetchFuelReceipts(vehicleId: UUID) async throws -> [FuelReceipt] {
        try await request("/api/vehicles/\(vehicleId.uuidString)/fuel-receipts")
    }

    func fetchExpenses(vehicleId: UUID) async throws -> [Expense] {
        try await request("/api/vehicles/\(vehicleId.uuidString)/expenses")
    }

    func createExpense(vehicleId: UUID, request: ExpenseRequest) async throws -> Expense {
        let data = try encoder.encode(request)
        return try await self.request("/api/vehicles/\(vehicleId.uuidString)/expenses", method: "POST", body: data)
    }

    func updateExpense(id: UUID, request: ExpenseRequest) async throws -> Expense {
        let data = try encoder.encode(request)
        return try await self.request("/api/expenses/\(id.uuidString)", method: "PUT", body: data)
    }

    func deleteExpense(id: UUID) async throws {
        try await requestNoContent("/api/expenses/\(id.uuidString)", method: "DELETE")
    }

    func fetchTireSets(vehicleId: UUID) async throws -> [TireSet] {
        try await request("/api/vehicles/\(vehicleId.uuidString)/tire-sets")
    }

    func createTireSet(vehicleId: UUID, request: TireSetRequest) async throws -> TireSet {
        let data = try encoder.encode(request)
        return try await self.request("/api/vehicles/\(vehicleId.uuidString)/tire-sets", method: "POST", body: data)
    }

    func updateTireSet(id: UUID, request: TireSetRequest) async throws -> TireSet {
        let data = try encoder.encode(request)
        return try await self.request("/api/tire-sets/\(id.uuidString)", method: "PUT", body: data)
    }

    func deleteTireSet(id: UUID) async throws {
        try await requestNoContent("/api/tire-sets/\(id.uuidString)", method: "DELETE")
    }

    func fetchEquipment(vehicleId: UUID) async throws -> [EquipmentItem] {
        try await request("/api/vehicles/\(vehicleId.uuidString)/equipment")
    }

    func createEquipment(vehicleId: UUID, request: EquipmentRequest) async throws -> EquipmentItem {
        let data = try encoder.encode(request)
        return try await self.request("/api/vehicles/\(vehicleId.uuidString)/equipment", method: "POST", body: data)
    }

    func updateEquipment(id: UUID, request: EquipmentRequest) async throws -> EquipmentItem {
        let data = try encoder.encode(request)
        return try await self.request("/api/equipment/\(id.uuidString)", method: "PUT", body: data)
    }

    func deleteEquipment(id: UUID) async throws {
        try await requestNoContent("/api/equipment/\(id.uuidString)", method: "DELETE")
    }

    func createFuelReceipt(vehicleId: UUID, draft: FuelReceiptDraft) async throws -> FuelReceipt {
        let data = try encoder.encode(draft)
        return try await request("/api/vehicles/\(vehicleId.uuidString)/fuel-receipts", method: "POST", body: data)
    }

    func uploadFuelReceipt(vehicleId: UUID, draft: FuelReceiptDraft, image: UIImage) async throws -> FuelReceipt {
        guard let imageData = image.jpegData(compressionQuality: 0.86) else {
            throw ApiError.emptyResponse
        }
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = try makeRequest(path: "/api/vehicles/\(vehicleId.uuidString)/fuel-receipts/with-image", method: "POST", requiresAuth: true)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = try multipartBody(boundary: boundary, metadata: draft, imageData: imageData)

        let (data, response) = try await session.data(for: request)
        return try decodeResponse(data: data, response: response)
    }

    func testConnection() async -> ConnectionTestResult {
        let trimmedBaseURL = config.apiBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseURLValue = trimmedBaseURL.isEmpty ? "http://localhost:8080" : trimmedBaseURL
        guard let baseURL = URL(string: baseURLValue), isValidBaseURL(baseURL) else {
            return .invalidURL
        }

        let hasToken = ((try? keychain.readToken()) ?? nil) != nil
        let path = hasToken ? "/api/auth/me" : "/api/health"

        do {
            let request = try makeRequest(path: path, method: "GET", requiresAuth: hasToken)
            let (_, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .cannotReachServer
            }
            if (200...299).contains(httpResponse.statusCode) {
                return .connected
            }
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                return .unauthorizedReachable
            }
            return .cannotReachServer
        } catch ApiError.invalidURL {
            return .invalidURL
        } catch let error as URLError {
            if error.code == .unsupportedURL || error.code == .badURL {
                return .invalidURL
            }
            return .cannotReachServer
        } catch {
            return .cannotReachServer
        }
    }

    private func request<T: Decodable>(
        _ path: String,
        method: String = "GET",
        body: Data? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        var request = try makeRequest(path: path, method: method, requiresAuth: requiresAuth)
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let (data, response) = try await session.data(for: request)
        return try decodeResponse(data: data, response: response)
    }

    private func requestNoContent(
        _ path: String,
        method: String,
        body: Data? = nil,
        requiresAuth: Bool = true
    ) async throws {
        var request = try makeRequest(path: path, method: method, requiresAuth: requiresAuth)
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let (data, response) = try await session.data(for: request)
        try validateNoContentResponse(data: data, response: response)
    }

    private func makeRequest(path: String, method: String, requiresAuth: Bool) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: config.normalizedBaseURL)?.absoluteURL else {
            throw ApiError.invalidURL
        }
#if DEBUG
        print("API \(method) \(url.absoluteString)")
#endif
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if requiresAuth {
            guard let token = try keychain.readToken() else { throw ApiError.missingToken }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func isValidBaseURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) else {
            return false
        }
        return url.host?.isEmpty == false
    }

    private func decodeResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.emptyResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = apiErrorMessage(from: data) ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw ApiError.requestFailed(httpResponse.statusCode, message)
        }
        guard !data.isEmpty else { throw ApiError.emptyResponse }
        return try decoder.decode(T.self, from: data)
    }

    private func validateNoContentResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.emptyResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = apiErrorMessage(from: data) ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw ApiError.requestFailed(httpResponse.statusCode, message)
        }
    }

    private func apiErrorMessage(from data: Data) -> String? {
        guard
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let message = object["message"] as? String
        else {
            return nil
        }
        return message
    }

    private func multipartBody(boundary: String, metadata: FuelReceiptDraft, imageData: Data) throws -> Data {
        var body = Data()
        let lineBreak = "\r\n"

        body.appendString("--\(boundary)\(lineBreak)")
        body.appendString("Content-Disposition: form-data; name=\"metadata\"\(lineBreak)")
        body.appendString("Content-Type: application/json\(lineBreak)\(lineBreak)")
        body.append(try encoder.encode(metadata))
        body.appendString(lineBreak)

        body.appendString("--\(boundary)\(lineBreak)")
        body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"fuel-receipt.jpg\"\(lineBreak)")
        body.appendString("Content-Type: image/jpeg\(lineBreak)\(lineBreak)")
        body.append(imageData)
        body.appendString(lineBreak)
        body.appendString("--\(boundary)--\(lineBreak)")
        return body
    }
}

private extension Data {
    mutating func appendString(_ value: String) {
        append(Data(value.utf8))
    }
}
