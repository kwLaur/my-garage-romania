import SwiftUI

struct LegalDocumentFormView: View {
    let vehicle: Vehicle
    let document: LegalDocument?
    let notificationPreference: NotificationPreference?
    let apiClient: ApiClient
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: LegalDocumentDraft
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(vehicle: Vehicle, document: LegalDocument? = nil, notificationPreference: NotificationPreference? = nil, type: String = LegalDocumentTypeOption.rca.rawValue, apiClient: ApiClient, onSaved: @escaping () -> Void) {
        self.vehicle = vehicle
        self.document = document
        self.notificationPreference = notificationPreference
        self.apiClient = apiClient
        self.onSaved = onSaved
        _draft = State(initialValue: LegalDocumentDraft(document: document, type: type))
    }

    var body: some View {
        Form {
            Section("Document") {
                Picker("Type", selection: $draft.type) {
                    ForEach(LegalDocumentTypeOption.allCases) { option in
                        Text(option.displayName).tag(option.rawValue)
                    }
                }
                OptionalDatePickerRow(title: "Start Date", value: $draft.startDate, defaultEnabled: true)
                OptionalDatePickerRow(title: "End Date", value: $draft.endDate)
                Toggle("Ignored", isOn: $draft.ignored)
            }

            Section("Details") {
                TextField("Provider", text: $draft.provider)
                    .textInputAutocapitalization(.words)
                TextField("Policy number", text: $draft.policyNumber)
                TextField("Document URL", text: $draft.documentUrl)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                TextField("Cost", text: $draft.cost)
                    .keyboardType(.decimalPad)
                Picker("Source", selection: $draft.source) {
                    ForEach(LegalDocumentSourceOption.allCases) { option in
                        Text(option.displayName).tag(option.rawValue)
                    }
                }
            }

            notesSection(text: $draft.notes)
            NotificationSettingsSection(
                target: notificationTarget,
                apiClient: apiClient,
                summary: notificationPreferenceSummary(notificationPreference),
                onSaved: { _ in onSaved() },
                onDeleted: onSaved
            )
            errorSection(errorMessage)
        }
        .navigationTitle(document == nil ? "Legal Document" : "Edit Document")
        .toolbar {
            formToolbar
        }
    }

    private var formToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
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
            if let document {
                _ = try await apiClient.updateLegalDocument(id: document.id, request: request)
            } else {
                _ = try await apiClient.createLegalDocument(vehicleId: vehicle.id, request: request)
            }
            onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var notificationTarget: NotificationSettingsTarget? {
        guard let document else { return nil }
        return NotificationSettingsTarget(
            vehicle: vehicle,
            entityType: .legalDocument,
            entityId: document.id,
            itemName: legalReminderName(document.type),
            dueDateString: document.endDate,
            initialPreference: notificationPreference
        )
    }
}

struct MaintenanceFormView: View {
    let vehicle: Vehicle
    let item: MaintenanceItem?
    let notificationPreference: NotificationPreference?
    let apiClient: ApiClient
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: MaintenanceDraft
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(vehicle: Vehicle, item: MaintenanceItem? = nil, notificationPreference: NotificationPreference? = nil, apiClient: ApiClient, onSaved: @escaping () -> Void) {
        self.vehicle = vehicle
        self.item = item
        self.notificationPreference = notificationPreference
        self.apiClient = apiClient
        self.onSaved = onSaved
        _draft = State(initialValue: MaintenanceDraft(item: item))
    }

    var body: some View {
        Form {
            Section("Maintenance") {
                Picker("Type", selection: $draft.type) {
                    ForEach(MaintenanceTypeOption.allCases) { option in
                        Text(option.displayName).tag(option.rawValue)
                    }
                }
                TextField("Last km", text: $draft.lastKm)
                    .keyboardType(.numberPad)
                OptionalDatePickerRow(title: "Last date", value: $draft.lastDate)
            }

            Section("Interval") {
                TextField("Interval km", text: $draft.intervalKm)
                    .keyboardType(.numberPad)
                TextField("Interval days", text: $draft.intervalDays)
                    .keyboardType(.numberPad)
                TextField("Cost", text: $draft.cost)
                    .keyboardType(.decimalPad)
            }

            notesSection(text: $draft.notes)
            NotificationSettingsSection(
                target: notificationTarget,
                apiClient: apiClient,
                summary: notificationPreferenceSummary(notificationPreference),
                onSaved: { _ in onSaved() },
                onDeleted: onSaved
            )
            errorSection(errorMessage)
        }
        .navigationTitle(item == nil ? "Maintenance" : "Edit Maintenance")
        .toolbar {
            formToolbar
        }
    }

    private var formToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
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
            if let item {
                _ = try await apiClient.updateMaintenance(id: item.id, request: request)
            } else {
                _ = try await apiClient.createMaintenance(vehicleId: vehicle.id, request: request)
            }
            onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var notificationTarget: NotificationSettingsTarget? {
        guard let item else { return nil }
        return NotificationSettingsTarget(
            vehicle: vehicle,
            entityType: .maintenance,
            entityId: item.id,
            itemName: MaintenanceType.displayName(item.type),
            dueDateString: item.nextDueDate,
            initialPreference: notificationPreference
        )
    }
}

struct ExpenseFormView: View {
    let vehicleId: UUID
    let expense: Expense?
    let apiClient: ApiClient
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: ExpenseDraft
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(vehicleId: UUID, expense: Expense? = nil, type: String = ExpenseTypeOption.service.rawValue, apiClient: ApiClient, onSaved: @escaping () -> Void) {
        self.vehicleId = vehicleId
        self.expense = expense
        self.apiClient = apiClient
        self.onSaved = onSaved
        _draft = State(initialValue: ExpenseDraft(expense: expense, type: type))
    }

    var body: some View {
        Form {
            Section("Expense") {
                TextField("Title", text: $draft.title)
                    .textInputAutocapitalization(.words)
                Picker("Type", selection: $draft.type) {
                    ForEach(ExpenseTypeOption.allCases) { option in
                        Text(option.displayName).tag(option.rawValue)
                    }
                }
                TextField("Amount", text: $draft.amount)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: requiredDateBinding($draft.date), displayedComponents: .date)
            }

            Section("Description") {
                TextField("Description", text: $draft.description, axis: .vertical)
                    .lineLimit(3...6)
            }

            errorSection(errorMessage)
        }
        .navigationTitle(expense == nil ? "Expense" : "Edit Expense")
        .toolbar {
            formToolbar
        }
    }

    private var formToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
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
            if let expense {
                _ = try await apiClient.updateExpense(id: expense.id, request: request)
            } else {
                _ = try await apiClient.createExpense(vehicleId: vehicleId, request: request)
            }
            onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct TireSetFormView: View {
    let vehicleId: UUID
    let tireSet: TireSet?
    let apiClient: ApiClient
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: TireSetDraft
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(vehicleId: UUID, tireSet: TireSet? = nil, apiClient: ApiClient, onSaved: @escaping () -> Void) {
        self.vehicleId = vehicleId
        self.tireSet = tireSet
        self.apiClient = apiClient
        self.onSaved = onSaved
        _draft = State(initialValue: TireSetDraft(tireSet: tireSet))
    }

    var body: some View {
        Form {
            Section("Tires") {
                Picker("Type", selection: $draft.tireType) {
                    ForEach(TireTypeOption.allCases) { option in
                        Text(option.displayName).tag(option.rawValue)
                    }
                }
                Picker("Mount", selection: $draft.mountType) {
                    ForEach(TireMountTypeOption.allCases) { option in
                        Text(option.displayName).tag(option.rawValue)
                    }
                }
                Toggle("Installed", isOn: $draft.installed)
            }

            Section("Details") {
                TextField("Brand / model", text: $draft.brandModel)
                    .textInputAutocapitalization(.words)
                TextField("Size", text: $draft.size)
                TextField("DOT", text: $draft.dot)
                OptionalDatePickerRow(title: "Purchase date", value: $draft.purchaseDate)
                TextField("Total km", text: $draft.totalKm)
                    .keyboardType(.numberPad)
                TextField("Cost", text: $draft.cost)
                    .keyboardType(.decimalPad)
            }

            Section("Storage") {
                TextField("Storage location", text: $draft.storageLocation)
                    .textInputAutocapitalization(.words)
                TextField("Front pressure", text: $draft.pressureFront)
                    .keyboardType(.decimalPad)
                TextField("Rear pressure", text: $draft.pressureRear)
                    .keyboardType(.decimalPad)
            }

            notesSection(text: $draft.notes)
            errorSection(errorMessage)
        }
        .navigationTitle(tireSet == nil ? "Tire Set" : "Edit Tire Set")
        .toolbar {
            formToolbar
        }
    }

    private var formToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
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
            if let tireSet {
                _ = try await apiClient.updateTireSet(id: tireSet.id, request: request)
            } else {
                _ = try await apiClient.createTireSet(vehicleId: vehicleId, request: request)
            }
            onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct EquipmentFormView: View {
    let vehicleId: UUID
    let item: EquipmentItem?
    let apiClient: ApiClient
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: EquipmentDraft
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(vehicleId: UUID, item: EquipmentItem? = nil, apiClient: ApiClient, onSaved: @escaping () -> Void) {
        self.vehicleId = vehicleId
        self.item = item
        self.apiClient = apiClient
        self.onSaved = onSaved
        _draft = State(initialValue: EquipmentDraft(item: item))
    }

    var body: some View {
        Form {
            Section("Equipment") {
                Picker("Type", selection: $draft.type) {
                    ForEach(EquipmentTypeOption.allCases) { option in
                        Text(option.displayName).tag(option.rawValue)
                    }
                }
                TextField("Name", text: $draft.name)
                    .textInputAutocapitalization(.words)
                Toggle("Present", isOn: $draft.present)
            }

            Section("Details") {
                OptionalDatePickerRow(title: "Purchase date", value: $draft.purchaseDate)
                OptionalDatePickerRow(title: "Expiry date", value: $draft.expiryDate)
                TextField("Location", text: $draft.location)
                    .textInputAutocapitalization(.words)
                TextField("Cost", text: $draft.cost)
                    .keyboardType(.decimalPad)
            }

            notesSection(text: $draft.notes)
            errorSection(errorMessage)
        }
        .navigationTitle(item == nil ? "Equipment" : "Edit Equipment")
        .toolbar {
            formToolbar
        }
    }

    private var formToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
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
            if let item {
                _ = try await apiClient.updateEquipment(id: item.id, request: request)
            } else {
                _ = try await apiClient.createEquipment(vehicleId: vehicleId, request: request)
            }
            onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@ViewBuilder
private func notesSection(text: Binding<String>) -> some View {
    Section("Notes") {
        TextField("Notes", text: text, axis: .vertical)
            .lineLimit(3...6)
    }
}

@ViewBuilder
private func errorSection(_ message: String?) -> some View {
    if let message {
        Section {
            Text(message)
                .foregroundStyle(.red)
        }
    }
}

private struct OptionalDatePickerRow: View {
    let title: LocalizedStringKey
    @Binding var value: String
    var defaultEnabled = false

    @State private var enabled: Bool
    @State private var selectedDate: Date

    init(title: LocalizedStringKey, value: Binding<String>, defaultEnabled: Bool = false) {
        self.title = title
        self._value = value
        self.defaultEnabled = defaultEnabled
        let initialDate = Date.fromLocalDateString(value.wrappedValue) ?? Date()
        self._selectedDate = State(initialValue: initialDate)
        self._enabled = State(initialValue: defaultEnabled || !value.wrappedValue.trimmed.isEmpty)
    }

    var body: some View {
        Toggle("Set date", isOn: $enabled)
            .onChange(of: enabled) { _, isEnabled in
                if isEnabled {
                    value = Date.localDateString(from: selectedDate)
                } else {
                    value = ""
                }
            }

        if enabled {
            DatePicker(title, selection: $selectedDate, displayedComponents: .date)
                .onChange(of: selectedDate) { _, newDate in
                    value = Date.localDateString(from: newDate)
                }
                .onAppear {
                    value = Date.localDateString(from: selectedDate)
                }
        }
    }
}

private func requiredDateBinding(_ value: Binding<String>) -> Binding<Date> {
    Binding {
        Date.fromLocalDateString(value.wrappedValue) ?? Date()
    } set: { newValue in
        value.wrappedValue = Date.localDateString(from: newValue)
    }
}
