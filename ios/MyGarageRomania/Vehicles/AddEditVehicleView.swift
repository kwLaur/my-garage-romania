import SwiftUI

struct AddEditVehicleView: View {
    let vehicle: Vehicle?
    let apiClient: ApiClient
    let onSaved: (Vehicle) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: VehicleFormDraft
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(vehicle: Vehicle? = nil, apiClient: ApiClient, onSaved: @escaping (Vehicle) -> Void) {
        self.vehicle = vehicle
        self.apiClient = apiClient
        self.onSaved = onSaved
        _draft = State(initialValue: VehicleFormDraft(vehicle: vehicle))
    }

    var body: some View {
        Form {
            Section("Vehicle") {
                TextField("Name", text: $draft.name)
                    .textInputAutocapitalization(.words)
                TextField("License plate", text: $draft.licensePlate)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                TextField("VIN", text: $draft.vin)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
            }

            Section("Details") {
                TextField("Brand", text: $draft.brand)
                    .textInputAutocapitalization(.words)
                TextField("Model", text: $draft.model)
                    .textInputAutocapitalization(.words)
                TextField("Year", text: $draft.year)
                    .keyboardType(.numberPad)
                TextField("Current km", text: $draft.currentKm)
                    .keyboardType(.numberPad)
            }

            Section("Profile") {
                TextField("Fuel profile", text: $draft.fuelProfile)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                TextField("Image URL", text: $draft.imageUrl)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Toggle("Active", isOn: $draft.active)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(vehicle == nil ? "Add Vehicle" : "Edit Vehicle")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .disabled(isSaving)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task { await save() }
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .disabled(isSaving)
            }
        }
    }

    private func save() async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            let request = try draft.makeRequest()
            let savedVehicle: Vehicle
            if let vehicle {
                savedVehicle = try await apiClient.updateVehicle(id: vehicle.id, request: request)
            } else {
                savedVehicle = try await apiClient.createVehicle(request)
            }
            onSaved(savedVehicle)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
