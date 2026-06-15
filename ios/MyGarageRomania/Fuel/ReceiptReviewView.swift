import SwiftUI
import UIKit

struct ReceiptReviewView: View {
    let vehicleId: UUID
    let apiClient: ApiClient
    let image: UIImage
    let parserWarnings: [String]
    let onRetake: () -> Void
    let onChooseAnother: () -> Void
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: FuelReceiptDraft
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showingRawText = false

    init(
        vehicleId: UUID,
        apiClient: ApiClient,
        image: UIImage,
        draft: FuelReceiptDraft,
        parserWarnings: [String],
        onRetake: @escaping () -> Void,
        onChooseAnother: @escaping () -> Void,
        onSaved: @escaping () -> Void
    ) {
        self.vehicleId = vehicleId
        self.apiClient = apiClient
        self.image = image
        self.parserWarnings = parserWarnings
        self.onRetake = onRetake
        self.onChooseAnother = onChooseAnother
        self.onSaved = onSaved
        _draft = State(initialValue: draft)
    }

    var body: some View {
        Form {
            Section {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .frame(maxWidth: .infinity)

                HStack {
                    Label("OCR confidence", systemImage: "text.viewfinder")
                    Spacer()
                    Text(confidencePercent.formatted(.number.precision(.fractionLength(0))) + "%")
                        .font(.headline)
                        .foregroundStyle(confidenceColor)
                }

                HStack {
                    Button {
                        onRetake()
                    } label: {
                        Label("Retake photo", systemImage: "camera.fill")
                    }

                    Spacer()

                    Button {
                        onChooseAnother()
                    } label: {
                        Label("Choose another image", systemImage: "photo.on.rectangle.angled")
                    }
                }
            }

            if !parserWarnings.isEmpty {
                Section("Parser Warnings") {
                    ForEach(parserWarnings, id: \.self) { warning in
                        Label(warning, systemImage: "exclamationmark.triangle.fill")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                }
            }

            FuelReceiptDraftForm(draft: $draft)

            if let rawText = draft.rawOcrText, !rawText.isEmpty {
                Section {
                    DisclosureGroup("View raw OCR text", isExpanded: $showingRawText) {
                        Text(rawText)
                            .font(.footnote.monospaced())
                            .textSelection(.enabled)
                    }
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Review Receipt")
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
                        Text("Upload")
                    }
                }
                .disabled(isSaving)
            }
        }
    }

    private var confidencePercent: Double {
        (draft.confidenceScore ?? 0) * 100
    }

    private var confidenceColor: Color {
        if confidencePercent >= 80 {
            return .green
        }
        if confidencePercent >= 60 {
            return .yellow
        }
        return .red
    }

    private func save() async {
        if let validationMessage = validationMessage() {
            errorMessage = validationMessage
            return
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            draft.source = "IOS_SCAN"
            _ = try await apiClient.uploadFuelReceipt(vehicleId: vehicleId, draft: draft, image: image)
            onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func validationMessage() -> String? {
        guard !vehicleId.uuidString.isEmpty else {
            return "Vehicle is required."
        }
        guard !draft.receiptDate.trimmed.isEmpty else {
            return "Date is required."
        }
        guard draft.totalAmount != nil else {
            return "Total amount is required."
        }
        if draft.fuelType != FuelType.electric.rawValue && draft.fuelType != FuelType.other.rawValue && draft.quantityLiters == nil {
            return "Quantity liters is required for fuel receipts."
        }
        return nil
    }
}
