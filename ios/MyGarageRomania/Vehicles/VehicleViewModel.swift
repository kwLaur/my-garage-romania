import Foundation

@MainActor
final class VehicleViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    @Published var alerts: [Alert] = []
    @Published var selectedVehicle: Vehicle?
    @Published var legalDocuments: [LegalDocument] = []
    @Published var maintenance: [MaintenanceItem] = []
    @Published var fuelReceipts: [FuelReceipt] = []
    @Published var expenses: [Expense] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let apiClient: ApiClient

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func loadVehicles() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let vehicles = apiClient.fetchVehicles()
            async let alerts = apiClient.fetchAlerts()
            self.vehicles = try await vehicles
            self.alerts = (try? await alerts) ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadDetail(vehicleId: UUID) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let vehicle = apiClient.fetchVehicle(id: vehicleId)
            async let legal = apiClient.fetchLegalDocuments(vehicleId: vehicleId)
            async let maintenance = apiClient.fetchMaintenance(vehicleId: vehicleId)
            async let receipts = apiClient.fetchFuelReceipts(vehicleId: vehicleId)
            async let expenses = apiClient.fetchExpenses(vehicleId: vehicleId)

            selectedVehicle = try await vehicle
            legalDocuments = (try? await legal) ?? []
            self.maintenance = (try? await maintenance) ?? []
            fuelReceipts = (try? await receipts) ?? []
            self.expenses = (try? await expenses) ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func alerts(for vehicle: Vehicle) -> [Alert] {
        alerts.filter { $0.vehicleId == vehicle.id }
    }

    func upsertVehicle(_ vehicle: Vehicle) {
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            vehicles[index] = vehicle
        } else {
            vehicles.insert(vehicle, at: 0)
        }
    }

    func latestFuelReceipt() -> FuelReceipt? {
        fuelReceipts.sorted { $0.receiptDate > $1.receiptDate }.first
    }

    func legalStatus(for type: String) -> LegalDocument? {
        legalDocuments
            .filter { $0.type == type }
            .sorted { ($0.endDate ?? "") > ($1.endDate ?? "") }
            .first
    }

    func nextMaintenance() -> MaintenanceItem? {
        maintenance.sorted { first, second in
            let firstRank = statusRank(first.status)
            let secondRank = statusRank(second.status)
            if firstRank != secondRank {
                return firstRank > secondRank
            }
            return (first.daysRemaining ?? Int.max) < (second.daysRemaining ?? Int.max)
        }.first
    }

    func yearlyCost() -> Double {
        let currentYear = Calendar.current.component(.year, from: Date())
        return expenses.reduce(0) { partial, expense in
            guard expense.date.hasPrefix("\(currentYear)-") else { return partial }
            return partial + expense.amount
        }
    }

    private func statusRank(_ status: String) -> Int {
        switch status {
        case "OVERDUE", "EXPIRED": 3
        case "SOON", "EXPIRING_SOON": 2
        case "UNKNOWN": 1
        default: 0
        }
    }
}
