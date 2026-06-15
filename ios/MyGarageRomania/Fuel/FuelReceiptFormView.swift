import SwiftUI

struct FuelReceiptFormView: View {
    let vehicleId: UUID
    let apiClient: ApiClient
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft = FuelReceiptDraft.emptyManual
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            FuelReceiptDraftForm(draft: $draft)

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Fuel Receipt")
        .toolbar {
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
            draft.source = "MANUAL"
            _ = try await apiClient.createFuelReceipt(vehicleId: vehicleId, draft: draft)
            onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct FuelReceiptDraftForm: View {
    @Binding var draft: FuelReceiptDraft

    var body: some View {
        Section("Receipt") {
            DatePicker("Date", selection: dateBinding, displayedComponents: .date)

            TextField("Station", text: $draft.stationName)
                .textInputAutocapitalization(.words)

            Picker("Fuel Type", selection: $draft.fuelType) {
                ForEach(FuelTypeOption.allCases) { option in
                    Text(option.displayName).tag(option.rawValue)
                }
            }

            Toggle("Full Tank", isOn: $draft.fullTank)
        }

        Section("Amounts") {
            TextField("Quantity liters", text: doubleBinding(\.quantityLiters))
                .keyboardType(.decimalPad)
            TextField("Unit price", text: doubleBinding(\.unitPrice))
                .keyboardType(.decimalPad)
            TextField("Total amount", text: doubleBinding(\.totalAmount))
                .keyboardType(.decimalPad)
            TextField("Odometer km", text: intBinding(\.odometerKm))
                .keyboardType(.numberPad)
        }

        Section("Notes") {
            TextField("Notes", text: optionalStringBinding(\.notes), axis: .vertical)
                .lineLimit(3...6)
        }
    }

    private var dateBinding: Binding<Date> {
        Binding {
            Self.dateFormatter.date(from: draft.receiptDate) ?? Date()
        } set: { newValue in
            draft.receiptDate = Self.dateFormatter.string(from: newValue)
        }
    }

    private func doubleBinding(_ keyPath: WritableKeyPath<FuelReceiptDraft, Double?>) -> Binding<String> {
        Binding {
            draft[keyPath: keyPath].map { String(format: "%.2f", $0) } ?? ""
        } set: { newValue in
            let normalized = newValue.replacingOccurrences(of: ",", with: ".")
            draft[keyPath: keyPath] = Double(normalized)
        }
    }

    private func intBinding(_ keyPath: WritableKeyPath<FuelReceiptDraft, Int?>) -> Binding<String> {
        Binding {
            draft[keyPath: keyPath].map(String.init) ?? ""
        } set: { newValue in
            draft[keyPath: keyPath] = Int(newValue)
        }
    }

    private func optionalStringBinding(_ keyPath: WritableKeyPath<FuelReceiptDraft, String?>) -> Binding<String> {
        Binding {
            draft[keyPath: keyPath] ?? ""
        } set: { newValue in
            draft[keyPath: keyPath] = newValue.nilIfEmpty
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
