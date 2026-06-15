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
                if viewModel.isLoading {
                    ProgressView("Refreshing")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }

                if let message = viewModel.errorMessage {
                    AppleCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Could not refresh vehicle", systemImage: "exclamationmark.triangle.fill")
                                .font(.headline)
                                .foregroundStyle(.orange)
                            Text(message)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            Button {
                                Task { await viewModel.loadDetail(vehicleId: vehicle.id) }
                            } label: {
                                Label("Retry", systemImage: "arrow.clockwise")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }

                OverviewSectionView(vehicle: viewModel.selectedVehicle ?? vehicle) {
                    showingEditVehicle = true
                }
                LegalDocumentsSectionView(vehicle: viewModel.selectedVehicle ?? vehicle, documents: viewModel.legalDocuments, notificationPreferences: viewModel.notificationPreferences, apiClient: viewModel.apiClient) {
                    Task { await viewModel.loadDetail(vehicleId: vehicle.id) }
                }
                MaintenanceSectionView(vehicle: viewModel.selectedVehicle ?? vehicle, items: viewModel.maintenance, notificationPreferences: viewModel.notificationPreferences, apiClient: viewModel.apiClient) {
                    Task { await viewModel.loadDetail(vehicleId: vehicle.id) }
                }
                FuelReceiptsSectionView(receipts: viewModel.fuelReceipts) {
                    showingManualForm = true
                } onScan: {
                    showingScanner = true
                }
                ExpensesSectionView(vehicleId: vehicle.id, expenses: viewModel.expenses, apiClient: viewModel.apiClient) {
                    Task { await viewModel.loadDetail(vehicleId: vehicle.id) }
                }
                TireSetsSectionView(vehicleId: vehicle.id, tireSets: viewModel.tireSets, apiClient: viewModel.apiClient) {
                    Task { await viewModel.loadDetail(vehicleId: vehicle.id) }
                }
                EquipmentSectionView(vehicleId: vehicle.id, equipment: viewModel.equipment, apiClient: viewModel.apiClient) {
                    Task { await viewModel.loadDetail(vehicleId: vehicle.id) }
                }
            }
            .padding(20)
        }
        .refreshable {
            await viewModel.loadDetail(vehicleId: vehicle.id)
        }
    }
}
