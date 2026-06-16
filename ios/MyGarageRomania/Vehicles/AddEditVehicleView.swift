import SwiftUI

struct AddEditVehicleView: View {
    let vehicle: Vehicle?
    let apiClient: ApiClient
    let onSaved: (Vehicle) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: VehicleFormDraft
    @State private var isSaving = false
    @State private var isLookingUp = false
    @State private var errorMessage: String?
    @State private var lookupResult: VehicleLookupResponse?
    @State private var licensePlateNotice: String?

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
                TextField("License Plate", text: $draft.licensePlate)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                TextField("VIN", text: $draft.vin)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                Button {
                    Task { await lookupVehicleData() }
                } label: {
                    if isLookingUp {
                        ProgressView()
                    } else {
                        Label("Lookup vehicle data", systemImage: "magnifyingglass")
                    }
                }
                .disabled(isSaving || isLookingUp)
                if let licensePlateNotice {
                    Text(licensePlateNotice)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
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
                TextField("Fuel Profile", text: $draft.fuelProfile)
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
        .sheet(item: $lookupResult) { result in
            NavigationStack {
                VehicleLookupResultView(result: result, onApply: {
                    applyLookupResult(result)
                    lookupResult = nil
                })
            }
        }
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

    private func lookupVehicleData() async {
        isLookingUp = true
        errorMessage = nil
        licensePlateNotice = nil
        defer { isLookingUp = false }

        do {
            let request = try VehicleLookupValidator.makeLookupRequest(vin: draft.vin, licensePlate: draft.licensePlate)
            if let normalizedPlate = request.licensePlate, normalizedPlate != draft.licensePlate.trimmed {
                draft.licensePlate = normalizedPlate
                licensePlateNotice = NSLocalizedString("License plate normalized", comment: "")
            }
            if let normalizedVin = request.vin {
                draft.vin = normalizedVin
            }
            lookupResult = try await apiClient.lookupVehicle(request)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func applyLookupResult(_ result: VehicleLookupResponse) {
        if let vin = result.vin {
            draft.vin = vin
        }
        if let licensePlate = result.licensePlate {
            draft.licensePlate = licensePlate
        }
        if let brand = result.brand {
            draft.brand = brand
        }
        if let model = result.model {
            draft.model = model
        }
        if let year = result.year {
            draft.year = String(year)
        }
        if let fuelProfile = result.fuelProfile {
            draft.fuelProfile = fuelProfile
        }
    }
}

struct VehicleLookupResultView: View {
    let result: VehicleLookupResponse
    let onApply: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form {
            Section("Vehicle lookup") {
                lookupRow("Brand", result.brand)
                lookupRow("Model", result.model)
                lookupRow("Year", result.year.map(String.init))
                lookupRow("Fuel Profile", result.fuelProfile)
                lookupRow("Rovinietă", result.rovinieta?.status)
                lookupRow("ITP", result.itp?.status)
                lookupRow("RAR Auto-Pass", result.rarAutoPass?.status)
            }

            if !result.warnings.isEmpty {
                Section("Warnings") {
                    ForEach(result.warnings, id: \.self) { warning in
                        Text(localizedLookupWarning(warning))
                            .font(.footnote)
                    }
                }
            }

            if !result.externalLinks.isEmpty {
                Section("External links") {
                    ForEach(result.externalLinks) { link in
                        Button(localizedExternalLinkLabel(link)) {
                            if let url = URL(string: link.url) {
                                openURL(url)
                            }
                        }
                    }
                    if result.externalLinks.contains(where: { $0.type == "CNAIR_ROVINIETA" }) {
                        Text("CNAIR verification requires license plate and VIN/chassis series.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Button("Apply lookup result") {
                    onApply()
                }
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
        .navigationTitle("Vehicle lookup")
    }

    @ViewBuilder
    private func lookupRow(_ title: LocalizedStringKey, _ value: String?) -> some View {
        LabeledContent(title) {
            Text(value?.nilIfEmpty ?? NSLocalizedString("Not set", comment: ""))
        }
    }

    private func localizedLookupWarning(_ warning: String) -> String {
        NSLocalizedString(warning, comment: "")
    }

    private func localizedExternalLinkLabel(_ link: VehicleLookupExternalLink) -> LocalizedStringKey {
        switch link.type {
        case "CNAIR_ROVINIETA":
            return "Open official CNAIR check"
        case "RAR_AUTOPASS":
            return "Open RAR Auto-Pass"
        default:
            return LocalizedStringKey(link.label)
        }
    }
}
