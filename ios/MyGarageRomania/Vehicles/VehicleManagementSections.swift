import SwiftUI

struct OverviewSectionView: View {
    let vehicle: Vehicle
    let onEdit: () -> Void

    var body: some View {
        AppleCard {
            VStack(alignment: .leading, spacing: 18) {
                DetailSectionHeader(title: "Overview", systemImage: "car.side.fill", addTitle: "Edit", addSystemImage: "pencil", action: onEdit)

                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(LinearGradient(colors: [.blue.opacity(0.92), .cyan.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Image(systemName: "car.side.rear.open.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 68, height: 68)

                    VStack(alignment: .leading, spacing: 7) {
                        Text(vehicle.licensePlate)
                            .font(.headline.monospaced().weight(.bold))
                            .foregroundStyle(.secondary)
                        Text(vehicle.name)
                            .font(.title2.bold())
                        if let brandLine {
                            Text(brandLine)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()
                }

                HStack(spacing: 12) {
                    SummaryPill(title: "Kilometers", value: "\(vehicle.currentKm ?? 0) km", systemImage: "gauge.with.dots.needle.50percent")
                    SummaryPill(title: "Fuel", value: vehicle.fuelProfile?.domainDisplayName ?? "Not set", systemImage: "fuelpump.fill")
                }
            }
        }
    }

    private var brandLine: String? {
        [vehicle.brand, vehicle.model, vehicle.year.map(String.init)]
            .compactMap { $0?.nilIfEmpty }
            .joined(separator: " ")
            .nilIfEmpty
    }
}

struct LegalDocumentsSectionView: View {
    let vehicle: Vehicle
    let documents: [LegalDocument]
    let notificationPreferences: [NotificationPreference]
    let apiClient: ApiClient
    let onChanged: () -> Void

    @State private var showingAdd = false
    @State private var addType = LegalDocumentTypeOption.rca.rawValue
    @State private var editingDocument: LegalDocument?
    @State private var notificationTarget: NotificationSettingsTarget?
    @State private var pendingDelete: LegalDocument?
    @State private var isWorking = false
    @State private var errorMessage: String?

    var body: some View {
        AppleCard {
            VStack(alignment: .leading, spacing: 14) {
                DetailSectionHeader(title: "Legal Documents", systemImage: "checkmark.shield.fill") {
                    showingAdd = true
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(LegalDocumentTypeOption.allCases) { option in
                        let document = latestDocument(for: option.rawValue)
                        StatusBadge(title: option.displayName, status: document?.status ?? "UNKNOWN")
                    }
                }

                if documents.isEmpty {
                    EmptySectionView(title: "No RCA/ITP records yet", systemImage: "doc.badge.plus")
                } else {
                    ForEach(sortedDocuments) { document in
                        let preference = notificationPreference(entityType: .legalDocument, entityId: document.id)
                        LegalDocumentRowView(document: document, notificationSummary: notificationPreferenceSummary(preference)) {
                            notificationTarget = NotificationSettingsTarget(
                                vehicle: vehicle,
                                entityType: .legalDocument,
                                entityId: document.id,
                                itemName: legalReminderName(document.type),
                                dueDateString: document.endDate,
                                initialPreference: preference
                            )
                        } onDelete: {
                            pendingDelete = document
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingDocument = document
                        }
                    }
                }

                workingAndErrorView(isWorking: isWorking, errorMessage: errorMessage)
            }
        }
        .sheet(isPresented: $showingAdd) {
            NavigationStack {
                LegalDocumentFormView(vehicle: vehicle, type: addType, apiClient: apiClient, onSaved: onChanged)
            }
        }
        .sheet(item: $editingDocument) { document in
            NavigationStack {
                LegalDocumentFormView(vehicle: vehicle, document: document, notificationPreference: notificationPreference(entityType: .legalDocument, entityId: document.id), apiClient: apiClient, onSaved: onChanged)
            }
        }
        .sheet(item: $notificationTarget) { target in
            NavigationStack {
                NotificationSettingsView(target: target, apiClient: apiClient) { _ in
                    onChanged()
                } onDeleted: {
                    onChanged()
                }
            }
        }
        .confirmationDialog("Delete legal document?", isPresented: deleteBinding) {
            Button("Delete", role: .destructive) {
                if let pendingDelete {
                    Task { await delete(pendingDelete) }
                }
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        }
    }

    private var sortedDocuments: [LegalDocument] {
        documents.sorted { ($0.endDate ?? "") > ($1.endDate ?? "") }
    }

    private func latestDocument(for type: String) -> LegalDocument? {
        documents
            .filter { $0.type == type }
            .sorted { ($0.endDate ?? "") > ($1.endDate ?? "") }
            .first
    }

    private func notificationPreference(entityType: NotificationPreferenceEntityType, entityId: UUID) -> NotificationPreference? {
        notificationPreferences.first { $0.entityType == entityType && $0.entityId == entityId }
    }

    private var deleteBinding: Binding<Bool> {
        Binding {
            pendingDelete != nil
        } set: { isPresented in
            if !isPresented {
                pendingDelete = nil
            }
        }
    }

    private func delete(_ document: LegalDocument) async {
        isWorking = true
        errorMessage = nil
        defer {
            isWorking = false
            pendingDelete = nil
        }

        do {
            try await apiClient.deleteLegalDocument(id: document.id)
            onChanged()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct LegalDocumentRowView: View {
    let document: LegalDocument
    let notificationSummary: String
    let onReminder: () -> Void
    let onDelete: () -> Void

    var body: some View {
        DetailRow(systemImage: "doc.text.fill", title: LegalDocumentType.displayName(document.type), subtitle: subtitle, trailing: trailing, onReminder: onReminder) {
            onDelete()
        }
    }

    private var subtitle: String {
        [
            document.provider?.nilIfEmpty,
            document.endDate.map { "Until \($0)" },
            document.daysRemaining.map { "\($0) days" },
            notificationSummary
        ]
        .compactMap { $0 }
        .joined(separator: " • ")
    }

    private var trailing: AnyView {
        AnyView(StatusBadge(title: "Status", status: document.status))
    }
}

struct MaintenanceSectionView: View {
    let vehicle: Vehicle
    let items: [MaintenanceItem]
    let notificationPreferences: [NotificationPreference]
    let apiClient: ApiClient
    let onChanged: () -> Void

    @State private var showingAdd = false
    @State private var editingItem: MaintenanceItem?
    @State private var notificationTarget: NotificationSettingsTarget?
    @State private var pendingDelete: MaintenanceItem?
    @State private var isWorking = false
    @State private var errorMessage: String?

    var body: some View {
        AppleCard {
            VStack(alignment: .leading, spacing: 14) {
                DetailSectionHeader(title: "Maintenance", systemImage: "wrench.and.screwdriver.fill") {
                    showingAdd = true
                }

                if let next = nextMaintenance {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(MaintenanceType.displayName(next.type))
                                .font(.title3.bold())
                            Text(maintenanceDueText(next))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        StatusBadge(title: "Status", status: next.status)
                    }
                }

                if items.isEmpty {
                    EmptySectionView(title: "No maintenance records yet", systemImage: "wrench.adjustable")
                } else {
                    ForEach(sortedItems) { item in
                        let preference = notificationPreference(entityType: .maintenance, entityId: item.id)
                        MaintenanceRowView(item: item, notificationSummary: notificationPreferenceSummary(preference)) {
                            notificationTarget = NotificationSettingsTarget(
                                vehicle: vehicle,
                                entityType: .maintenance,
                                entityId: item.id,
                                itemName: MaintenanceType.displayName(item.type),
                                dueDateString: item.nextDueDate,
                                initialPreference: preference
                            )
                        } onDelete: {
                            pendingDelete = item
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingItem = item
                        }
                    }
                }

                workingAndErrorView(isWorking: isWorking, errorMessage: errorMessage)
            }
        }
        .sheet(isPresented: $showingAdd) {
            NavigationStack {
                MaintenanceFormView(vehicle: vehicle, apiClient: apiClient, onSaved: onChanged)
            }
        }
        .sheet(item: $editingItem) { item in
            NavigationStack {
                MaintenanceFormView(vehicle: vehicle, item: item, notificationPreference: notificationPreference(entityType: .maintenance, entityId: item.id), apiClient: apiClient, onSaved: onChanged)
            }
        }
        .sheet(item: $notificationTarget) { target in
            NavigationStack {
                NotificationSettingsView(target: target, apiClient: apiClient) { _ in
                    onChanged()
                } onDeleted: {
                    onChanged()
                }
            }
        }
        .confirmationDialog("Delete maintenance item?", isPresented: deleteBinding) {
            Button("Delete", role: .destructive) {
                if let pendingDelete {
                    Task { await delete(pendingDelete) }
                }
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        }
    }

    private var sortedItems: [MaintenanceItem] {
        items.sorted { first, second in
            statusRank(first.status) > statusRank(second.status)
        }
    }

    private var nextMaintenance: MaintenanceItem? {
        sortedItems.first
    }

    private func notificationPreference(entityType: NotificationPreferenceEntityType, entityId: UUID) -> NotificationPreference? {
        notificationPreferences.first { $0.entityType == entityType && $0.entityId == entityId }
    }

    private var deleteBinding: Binding<Bool> {
        Binding {
            pendingDelete != nil
        } set: { isPresented in
            if !isPresented {
                pendingDelete = nil
            }
        }
    }

    private func delete(_ item: MaintenanceItem) async {
        isWorking = true
        errorMessage = nil
        defer {
            isWorking = false
            pendingDelete = nil
        }

        do {
            try await apiClient.deleteMaintenance(id: item.id)
            onChanged()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct MaintenanceRowView: View {
    let item: MaintenanceItem
    let notificationSummary: String
    let onReminder: () -> Void
    let onDelete: () -> Void

    var body: some View {
        DetailRow(systemImage: "wrench.fill", title: MaintenanceType.displayName(item.type), subtitle: subtitle, trailing: AnyView(StatusBadge(title: "Status", status: item.status)), onReminder: onReminder) {
            onDelete()
        }
    }

    private var subtitle: String {
        [
            item.lastKm.map { "Last \($0) km" },
            item.lastDate,
            maintenanceDueText(item),
            notificationSummary
        ]
        .compactMap { $0?.nilIfEmpty }
        .joined(separator: " • ")
    }
}

struct FuelReceiptsSectionView: View {
    let receipts: [FuelReceipt]
    let onAdd: () -> Void
    let onScan: () -> Void

    var body: some View {
        AppleCard {
            VStack(alignment: .leading, spacing: 14) {
                DetailSectionHeader(title: "Fuel Receipts", systemImage: "fuelpump.fill") {
                    onAdd()
                }

                HStack(spacing: 10) {
                    Button {
                        onScan()
                    } label: {
                        Label("Scan", systemImage: "doc.viewfinder")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        onAdd()
                    } label: {
                        Label("Add", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                if let latest = latestReceipt {
                    FuelReceiptSummaryRow(receipt: latest)
                } else {
                    EmptySectionView(title: "No fuel receipts yet", systemImage: "fuelpump")
                }
            }
        }
    }

    private var latestReceipt: FuelReceipt? {
        receipts.sorted { $0.receiptDate > $1.receiptDate }.first
    }
}

struct ExpensesSectionView: View {
    let vehicleId: UUID
    let expenses: [Expense]
    let apiClient: ApiClient
    let onChanged: () -> Void

    @State private var showingAdd = false
    @State private var editingExpense: Expense?
    @State private var pendingDelete: Expense?
    @State private var isWorking = false
    @State private var errorMessage: String?

    var body: some View {
        AppleCard {
            VStack(alignment: .leading, spacing: 14) {
                DetailSectionHeader(title: "Expenses", systemImage: "chart.pie.fill") {
                    showingAdd = true
                }

                HStack(spacing: 12) {
                    SummaryPill(title: "This year", value: money(yearlyCost), systemImage: "calendar")
                    SummaryPill(title: "Records", value: "\(expenses.count)", systemImage: "list.bullet")
                }

                if expenses.isEmpty {
                    EmptySectionView(title: "No expense records yet", systemImage: "creditcard")
                } else {
                    ForEach(sortedExpenses) { expense in
                        ExpenseRowView(expense: expense) {
                            pendingDelete = expense
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingExpense = expense
                        }
                    }
                }

                workingAndErrorView(isWorking: isWorking, errorMessage: errorMessage)
            }
        }
        .sheet(isPresented: $showingAdd) {
            NavigationStack {
                ExpenseFormView(vehicleId: vehicleId, apiClient: apiClient, onSaved: onChanged)
            }
        }
        .sheet(item: $editingExpense) { expense in
            NavigationStack {
                ExpenseFormView(vehicleId: vehicleId, expense: expense, apiClient: apiClient, onSaved: onChanged)
            }
        }
        .confirmationDialog("Delete expense?", isPresented: deleteBinding) {
            Button("Delete", role: .destructive) {
                if let pendingDelete {
                    Task { await delete(pendingDelete) }
                }
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        }
    }

    private var sortedExpenses: [Expense] {
        expenses.sorted { $0.date > $1.date }
    }

    private var yearlyCost: Double {
        let currentYear = Calendar.current.component(.year, from: Date())
        return expenses.reduce(0) { partial, expense in
            guard expense.date.hasPrefix("\(currentYear)-") else { return partial }
            return partial + expense.amount
        }
    }

    private var deleteBinding: Binding<Bool> {
        Binding {
            pendingDelete != nil
        } set: { isPresented in
            if !isPresented {
                pendingDelete = nil
            }
        }
    }

    private func delete(_ expense: Expense) async {
        isWorking = true
        errorMessage = nil
        defer {
            isWorking = false
            pendingDelete = nil
        }

        do {
            try await apiClient.deleteExpense(id: expense.id)
            onChanged()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    let onDelete: () -> Void

    var body: some View {
        DetailRow(systemImage: "creditcard.fill", title: expense.title, subtitle: subtitle, trailing: AnyView(Text(money(expense.amount)).font(.subheadline.bold()))) {
            onDelete()
        }
    }

    private var subtitle: String {
        [ExpenseType.displayName(expense.type), expense.date, expense.description?.nilIfEmpty]
            .compactMap { $0 }
            .joined(separator: " • ")
    }
}

struct TireSetsSectionView: View {
    let vehicleId: UUID
    let tireSets: [TireSet]
    let apiClient: ApiClient
    let onChanged: () -> Void

    @State private var showingAdd = false
    @State private var editingTireSet: TireSet?
    @State private var pendingDelete: TireSet?
    @State private var isWorking = false
    @State private var errorMessage: String?

    var body: some View {
        AppleCard {
            VStack(alignment: .leading, spacing: 14) {
                DetailSectionHeader(title: "Tires", systemImage: "circle.grid.cross.fill") {
                    showingAdd = true
                }

                if let installed = tireSets.first(where: { $0.installed }) {
                    SummaryPill(title: "Installed", value: installed.tireType.localizedDomainLabel(namespace: "tire.type"), systemImage: "checkmark.circle.fill")
                }

                if tireSets.isEmpty {
                    EmptySectionView(title: "No tire sets yet", systemImage: "circle.grid.cross")
                } else {
                    ForEach(tireSets) { tireSet in
                        TireSetRowView(tireSet: tireSet) {
                            pendingDelete = tireSet
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingTireSet = tireSet
                        }
                    }
                }

                workingAndErrorView(isWorking: isWorking, errorMessage: errorMessage)
            }
        }
        .sheet(isPresented: $showingAdd) {
            NavigationStack {
                TireSetFormView(vehicleId: vehicleId, apiClient: apiClient, onSaved: onChanged)
            }
        }
        .sheet(item: $editingTireSet) { tireSet in
            NavigationStack {
                TireSetFormView(vehicleId: vehicleId, tireSet: tireSet, apiClient: apiClient, onSaved: onChanged)
            }
        }
        .confirmationDialog("Delete tire set?", isPresented: deleteBinding) {
            Button("Delete", role: .destructive) {
                if let pendingDelete {
                    Task { await delete(pendingDelete) }
                }
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        }
    }

    private var deleteBinding: Binding<Bool> {
        Binding {
            pendingDelete != nil
        } set: { isPresented in
            if !isPresented {
                pendingDelete = nil
            }
        }
    }

    private func delete(_ tireSet: TireSet) async {
        isWorking = true
        errorMessage = nil
        defer {
            isWorking = false
            pendingDelete = nil
        }

        do {
            try await apiClient.deleteTireSet(id: tireSet.id)
            onChanged()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct TireSetRowView: View {
    let tireSet: TireSet
    let onDelete: () -> Void

    var body: some View {
        DetailRow(systemImage: "circle.grid.cross.fill", title: title, subtitle: subtitle, trailing: AnyView(status)) {
            onDelete()
        }
    }

    private var title: String {
        tireSet.brandModel?.nilIfEmpty ?? tireSet.tireType.localizedDomainLabel(namespace: "tire.type")
    }

    private var subtitle: String {
        [
            tireSet.tireType.localizedDomainLabel(namespace: "tire.type"),
            tireSet.mountType.localizedDomainLabel(namespace: "tire.mount"),
            tireSet.size?.nilIfEmpty,
            tireSet.totalKm.map { "\($0) km" }
        ]
        .compactMap { $0 }
        .joined(separator: " • ")
    }

    private var status: some View {
        Text(tireSet.installed ? "Installed" : "Stored")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background((tireSet.installed ? Color.green : Color.gray).opacity(0.13), in: Capsule())
            .foregroundStyle(tireSet.installed ? .green : .gray)
    }
}

struct EquipmentSectionView: View {
    let vehicleId: UUID
    let equipment: [EquipmentItem]
    let apiClient: ApiClient
    let onChanged: () -> Void

    @State private var showingAdd = false
    @State private var editingItem: EquipmentItem?
    @State private var pendingDelete: EquipmentItem?
    @State private var isWorking = false
    @State private var errorMessage: String?

    var body: some View {
        AppleCard {
            VStack(alignment: .leading, spacing: 14) {
                DetailSectionHeader(title: "Equipment", systemImage: "shippingbox.fill") {
                    showingAdd = true
                }

                HStack(spacing: 12) {
                    SummaryPill(title: "Present", value: "\(equipment.filter(\.present).count)", systemImage: "checkmark.circle.fill")
                    SummaryPill(title: "Missing", value: "\(equipment.filter { !$0.present }.count)", systemImage: "exclamationmark.circle.fill")
                }

                if equipment.isEmpty {
                    EmptySectionView(title: "No equipment records yet", systemImage: "shippingbox")
                } else {
                    ForEach(equipment) { item in
                        EquipmentRowView(item: item) {
                            pendingDelete = item
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingItem = item
                        }
                    }
                }

                workingAndErrorView(isWorking: isWorking, errorMessage: errorMessage)
            }
        }
        .sheet(isPresented: $showingAdd) {
            NavigationStack {
                EquipmentFormView(vehicleId: vehicleId, apiClient: apiClient, onSaved: onChanged)
            }
        }
        .sheet(item: $editingItem) { item in
            NavigationStack {
                EquipmentFormView(vehicleId: vehicleId, item: item, apiClient: apiClient, onSaved: onChanged)
            }
        }
        .confirmationDialog("Delete equipment?", isPresented: deleteBinding) {
            Button("Delete", role: .destructive) {
                if let pendingDelete {
                    Task { await delete(pendingDelete) }
                }
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        }
    }

    private var deleteBinding: Binding<Bool> {
        Binding {
            pendingDelete != nil
        } set: { isPresented in
            if !isPresented {
                pendingDelete = nil
            }
        }
    }

    private func delete(_ item: EquipmentItem) async {
        isWorking = true
        errorMessage = nil
        defer {
            isWorking = false
            pendingDelete = nil
        }

        do {
            try await apiClient.deleteEquipment(id: item.id)
            onChanged()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct EquipmentRowView: View {
    let item: EquipmentItem
    let onDelete: () -> Void

    var body: some View {
        DetailRow(systemImage: "shippingbox.fill", title: title, subtitle: subtitle, trailing: AnyView(status)) {
            onDelete()
        }
    }

    private var title: String {
        item.name?.nilIfEmpty ?? item.type.localizedDomainLabel(namespace: "equipment.type")
    }

    private var subtitle: String {
        [
            item.type.localizedDomainLabel(namespace: "equipment.type"),
            item.expiryDate.map { "Expires \($0)" },
            item.location?.nilIfEmpty
        ]
        .compactMap { $0 }
        .joined(separator: " • ")
    }

    private var status: some View {
        Text(item.present ? "Present" : "Missing")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background((item.present ? Color.green : Color.red).opacity(0.13), in: Capsule())
            .foregroundStyle(item.present ? .green : .red)
    }
}

private struct DetailSectionHeader: View {
    let title: String
    let systemImage: String
    var addTitle = "Add"
    var addSystemImage = "plus"
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)
            Spacer()
            Button(action: action) {
                Label(addTitle, systemImage: addSystemImage)
                    .labelStyle(.iconOnly)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.bordered)
            .clipShape(Circle())
            .accessibilityLabel(addTitle)
        }
    }
}

private struct SummaryPill: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct EmptySectionView: View {
    let title: String
    let systemImage: String

    var body: some View {
        ContentUnavailableView(title, systemImage: systemImage)
            .font(.footnote)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
    }
}

private struct DetailRow<Trailing: View>: View {
    let systemImage: String
    let title: String
    let subtitle: String
    let trailing: Trailing
    var onReminder: (() -> Void)? = nil
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(.blue)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 8)

            trailing

            if let onReminder {
                Button {
                    onReminder()
                } label: {
                    Image(systemName: "bell.badge")
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Reminder settings")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Delete")
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct FuelReceiptSummaryRow: View {
    let receipt: FuelReceipt

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "fuelpump.fill")
                .font(.headline)
                .foregroundStyle(.blue)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 4) {
                Text(receipt.stationName?.nilIfEmpty ?? "Fuel receipt")
                    .font(.subheadline.weight(.semibold))
                Text(receipt.receiptDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(money(receipt.totalAmount))
                .font(.subheadline.bold())
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

@ViewBuilder
private func workingAndErrorView(isWorking: Bool, errorMessage: String?) -> some View {
    if isWorking {
        ProgressView("Updating")
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    if let errorMessage {
        Text(errorMessage)
            .font(.footnote)
            .foregroundStyle(.red)
    }
}

private func maintenanceDueText(_ item: MaintenanceItem) -> String {
    if let dueKm = item.nextDueKm, let dueDate = item.nextDueDate {
        return "Due at \(dueKm) km or \(dueDate)"
    }
    if let dueKm = item.nextDueKm {
        return "Due at \(dueKm) km"
    }
    if let dueDate = item.nextDueDate {
        return "Due on \(dueDate)"
    }
    if let km = item.kmRemaining {
        return "\(km) km remaining"
    }
    if let days = item.daysRemaining {
        return "\(days) days remaining"
    }
    return "Schedule not set"
}

private func statusRank(_ status: String) -> Int {
    switch status {
    case "OVERDUE", "EXPIRED":
        3
    case "SOON", "EXPIRING_SOON":
        2
    case "UNKNOWN":
        1
    default:
        0
    }
}

private func money(_ amount: Double?) -> String {
    guard let amount else { return "-" }
    return amount.formatted(.currency(code: "RON"))
}
