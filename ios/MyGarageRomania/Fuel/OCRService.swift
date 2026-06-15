import Foundation
import ImageIO
import UIKit
import Vision

struct OCRResult: Hashable {
    let text: String
    let confidence: Double
}

enum OCRError: LocalizedError {
    case invalidImage

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            "The selected image could not be read."
        }
    }
}

final class OCRService {
    func recognizeText(in image: UIImage) async throws -> OCRResult {
        guard let cgImage = image.cgImage else { throw OCRError.invalidImage }

        return try await Task.detached(priority: .userInitiated) {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["ro-RO", "en-US"]

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation), options: [:])
            try handler.perform([request])

            let observations = request.results ?? []
            let candidates = observations.compactMap { $0.topCandidates(1).first }
            let text = candidates.map(\.string).joined(separator: "\n")
            let confidence = candidates.isEmpty ? 0 : Double(candidates.map(\.confidence).reduce(0, +) / Float(candidates.count))
            return OCRResult(text: text, confidence: confidence)
        }.value
    }
}

private extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
