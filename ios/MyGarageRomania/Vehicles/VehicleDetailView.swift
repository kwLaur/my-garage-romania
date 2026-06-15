import SwiftUI

struct VehicleDetailView: View {
    let vehicle: Vehicle
    @StateObject var viewModel: VehicleViewModel
    let onVehicleChanged: ((Vehicle) -> Void)?
    @State private var showingManualForm = false
    @State private var showingScanner = false
    @State private var showingEditVehicle = false

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.selectedVehicle == nil {
                LoadingView(title: "Loading vehicle")
            } else if let message = viewModel.errorMessage, viewModel.selectedVehicle == nil {
                ErrorView(message: message) {
                    Task { await viewModel.loadDetail(vehicleId: vehicle.id) }
                }
            } else {
                content
            }
        }
        .navigationTitle(viewModel.selectedVehicle?.name ?? vehicle.name)
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditVehicle = true
                }
            }
        }
        .task {
            if viewModel.selectedVehicle == nil {
                await viewModel.loadDetail(vehicleId: vehicle.id)
            }
        }
        .sheet(isPresented: $showingManualForm) {
            NavigationStack {
                FuelReceiptFormView(vehicleId: vehicle.id, apiClient: viewModel.apiClient) {
                    Task { await viewModel.loadDetail(vehicleId: vehicle.id) }
                    showingManualForm = false
                }
            }
        }
        .sheet(isPresented: $showingScanner) {
            NavigationStack {
                ReceiptScannerView(vehicleId: vehicle.id, apiClient: viewModel.apiClient) {
                    Task { await viewModel.loadDetail(vehicleId: vehicle.id) }
                    showingScanner = false
                }
            }
        }
        .sheet(isPresented: $showingEditVehicle) {
            NavigationStack {
                AddEditVehicleView(vehicle: viewModel.selectedVehicle ?? vehicle, apiClient: viewModel.apiClient) { savedVehicle in
                    viewModel.selectedVehicle = savedVehicle
                    Task { await viewModel.loadDetail(vehicleId: savedVehicle.id) }
                    onVehicleChanged?(savedVehicle)
                    showingEditVehicle = false
                }
            }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                heroCard
                legalSection
                maintenanceSection
                fuelSection
                costSection
            }
            .padding(20)
        }
        .refreshable {
            await viewModel.loadDetail(vehicleId: vehicle.id)
        }
    }

    private var heroCard: some View {
        AppleCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.selectedVehicle?.licensePlate ?? vehicle.licensePlate)
                            .font(.headline.monospaced().weight(.bold))
                            .foregroundStyle(.secondary)
                        Text("\(viewModel.selectedVehicle?.currentKm ?? vehicle.currentKm ?? 0) km")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                    }
                    Spacer()
                    Image(systemName: "car.side.rear.open.fill")
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(.blue)
                }

                HStack(spacing: 12) {
                    Button {
                        showingScanner = true
                    } label: {
                        Label("Scan Fuel Receipt", systemImage: "doc.viewfinder")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button {
                        showingManualForm = true
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .accessibilityLabel("Add manually")
                }
            }
        }
    }

    private var legalSection: some View {
        AppleCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("Documents", systemImage: "checkmark.shield.fill")
                    .font(.headline)
                FlowLayout(spacing: 8) {
                    StatusBadge(title: "RCA", status: viewModel.legalStatus(for: "RCA")?.status ?? "UNKNOWN")
                    StatusBadge(title: "ITP", status: viewModel.legalStatus(for: "ITP")?.status ?? "UNKNOWN")
                    StatusBadge(title: "Rovinieta", status: viewModel.legalStatus(for: "ROVINIETA")?.status ?? "UNKNOWN")
                }
            }
        }
    }

    private var maintenanceSection: some View {
        AppleCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Next Maintenance", systemImage: "wrench.and.screwdriver.fill")
                    .font(.headline)
                if let item = viewModel.nextMaintenance() {
                    Text(item.type.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.title3.bold())
                    Text(maintenanceDetail(item))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    StatusBadge(title: "Status", status: item.status)
                } else {
                    Text("No maintenance items yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var fuelSection: some View {
        AppleCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Latest Fuel Receipt", systemImage: "fuelpump.fill")
                    .font(.headline)
                if let receipt = viewModel.latestFuelReceipt() {
                    Text(receipt.stationName?.nilIfEmpty ?? "Fuel receipt")
                        .font(.title3.bold())
                    HStack {
                        Text(receipt.receiptDate)
                        Spacer()
                        Text(currency(receipt.totalAmount))
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                } else {
                    Text("No fuel receipts yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var costSection: some View {
        AppleCard {
            HStack {
                Label("Yearly Cost", systemImage: "chart.pie.fill")
                    .font(.headline)
                Spacer()
                Text(currency(viewModel.yearlyCost()))
                    .font(.title3.bold())
            }
        }
    }

    private func maintenanceDetail(_ item: MaintenanceItem) -> String {
        if let dueKm = item.nextDueKm {
            return "Due at \(dueKm) km"
        }
        if let dueDate = item.nextDueDate {
            return "Due on \(dueDate)"
        }
        return "Schedule not set"
    }

    private func currency(_ amount: Double?) -> String {
        guard let amount else { return "—" }
        return amount.formatted(.currency(code: "RON"))
    }
}

private struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: Content

    init(spacing: CGFloat, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        HStack(spacing: spacing) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
