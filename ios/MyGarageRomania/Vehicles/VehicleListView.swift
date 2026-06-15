import SwiftUI

struct VehicleListView: View {
    @StateObject var viewModel: VehicleViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var showingAddVehicle = false

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.vehicles.isEmpty {
                LoadingView(title: "Loading garage")
            } else if let message = viewModel.errorMessage, viewModel.vehicles.isEmpty {
                ErrorView(message: message) {
                    Task { await viewModel.loadVehicles() }
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if viewModel.isLoading {
                            ProgressView("Refreshing")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }

                        if let message = viewModel.errorMessage {
                            AppleCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    Label("Could not refresh vehicles", systemImage: "exclamationmark.triangle.fill")
                                        .font(.headline)
                                        .foregroundStyle(.orange)
                                    Text(message)
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                    Button {
                                        Task { await viewModel.loadVehicles() }
                                    } label: {
                                        Label("Retry", systemImage: "arrow.clockwise")
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                        }

                        if viewModel.vehicles.isEmpty {
                            AppleCard {
                                ContentUnavailableView(
                                    "No Vehicles",
                                    systemImage: "car.2",
                                    description: Text("Add your first vehicle to start tracking garage activity.")
                                )
                            }
                        } else {
                            ForEach(viewModel.vehicles) { vehicle in
                                NavigationLink {
                                    VehicleDetailView(
                                        vehicle: vehicle,
                                        viewModel: VehicleViewModel(apiClient: viewModel.apiClient)
                                    ) { changedVehicle in
                                        viewModel.upsertVehicle(changedVehicle)
                                        Task { await viewModel.loadVehicles() }
                                    }
                                } label: {
                                    VehicleCard(vehicle: vehicle, alerts: viewModel.alerts(for: vehicle))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(20)
                }
                .refreshable {
                    await viewModel.loadVehicles()
                }
            }
        }
        .navigationTitle("Garage")
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddVehicle = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add vehicle")
            }
        }
        .onAppear {
            Task { await viewModel.loadVehicles() }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await viewModel.loadVehicles() }
            }
        }
        .sheet(isPresented: $showingAddVehicle) {
            NavigationStack {
                AddEditVehicleView(apiClient: viewModel.apiClient) { savedVehicle in
                    viewModel.upsertVehicle(savedVehicle)
                    Task { await viewModel.loadVehicles() }
                    showingAddVehicle = false
                }
            }
        }
    }

}

private struct VehicleCard: View {
    let vehicle: Vehicle
    let alerts: [Alert]

    var body: some View {
        AppleCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(LinearGradient(colors: [.blue.opacity(0.92), .cyan.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Image(systemName: "car.side.fill")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 64, height: 64)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(vehicle.name)
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        Text(vehicle.licensePlate)
                            .font(.subheadline.monospaced().weight(.semibold))
                            .foregroundStyle(.secondary)
                        if let brandLine {
                            Text(brandLine)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .padding(.top, 6)
                }

                HStack {
                    Label("\(vehicle.currentKm ?? 0) km", systemImage: "gauge.with.dots.needle.50percent")
                    Spacer()
                    if let urgent = alerts.first(where: { $0.severity == "URGENT" }) {
                        StatusBadge(title: urgent.category, status: "URGENT")
                    } else if !alerts.isEmpty {
                        StatusBadge(title: "Alerts", status: "SOON")
                    } else {
                        StatusBadge(title: "Ready", status: "OK")
                    }
                }
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
            }
        }
    }

    private var brandLine: String? {
        [vehicle.brand, vehicle.model, vehicle.year.map(String.init)]
            .compactMap { $0 }
            .joined(separator: " ")
            .nilIfEmpty
    }
}
