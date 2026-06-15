import PhotosUI
import SwiftUI
import UIKit

struct ReceiptScannerView: View {
    let vehicleId: UUID
    let apiClient: ApiClient
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var reviewDraft: FuelReceiptDraft?
    @State private var reviewWarnings: [String] = []
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var showingReview = false
    @State private var isProcessing = false
    @State private var errorMessage: String?

    private let ocrService = OCRService()

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "doc.viewfinder.fill")
                .font(.system(size: 58, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.blue)

            VStack(spacing: 8) {
                Text("Scan Fuel Receipt")
                    .font(.title.bold())
                Text("Take a clear photo or pick one from your library. OCR runs on device and you review every value before upload.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 12) {
                Button {
                    showingCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera) || isProcessing)

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle.angled")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(isProcessing)
            }
            .padding(.horizontal, 28)

            if isProcessing {
                ProgressView("Reading receipt")
                    .padding(.top, 8)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Receipt Scanner")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            Task { await loadPhoto(newItem) }
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedItem, matching: .images)
        .fullScreenCover(isPresented: $showingCamera) {
            CameraCaptureView { image in
                showingCamera = false
                Task { await process(image) }
            } onCancel: {
                showingCamera = false
            }
        }
        .sheet(isPresented: $showingReview) {
            if let selectedImage, let reviewDraft {
                NavigationStack {
                    ReceiptReviewView(
                        vehicleId: vehicleId,
                        apiClient: apiClient,
                        image: selectedImage,
                        draft: reviewDraft,
                        parserWarnings: reviewWarnings,
                        onRetake: {
                            showingReview = false
                            showingCamera = true
                        },
                        onChooseAnother: {
                            showingReview = false
                            showingPhotoPicker = true
                        }
                    ) {
                        onSaved()
                        dismiss()
                    }
                }
            }
        }
    }

    private func loadPhoto(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self), let image = UIImage(data: data) else {
                throw OCRError.invalidImage
            }
            await process(image)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func process(_ image: UIImage) async {
        selectedImage = image
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        do {
            let ocr = try await ocrService.recognizeText(in: image)
            let parsed = ReceiptParser.parse(ocr.text)
            reviewDraft = parsed.draft()
            reviewWarnings = parsed.warnings
            showingReview = true
        } catch {
            var draft = FuelReceiptDraft.emptyManual
            draft.source = "IOS_SCAN"
            draft.rawOcrText = ""
            draft.confidenceScore = 0
            reviewDraft = draft
            reviewWarnings = ["OCR could not read the image. Enter the receipt values manually."]
            errorMessage = error.localizedDescription
            showingReview = true
        }
    }
}

struct CameraCaptureView: UIViewControllerRepresentable {
    let onImage: (UIImage) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImage: onImage, onCancel: onCancel)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onImage: (UIImage) -> Void
        let onCancel: () -> Void

        init(onImage: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onImage = onImage
            self.onCancel = onCancel
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImage(image)
            } else {
                onCancel()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancel()
        }
    }
}
