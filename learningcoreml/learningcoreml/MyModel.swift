//
//  MyModel.swift
//  learningcoreml
//
//  Created by Nigel Tan Yong on 24/1/24.
//

import CoreML

class MyModel {
    // The Core ML model instance
    var model: MNISTClassifier
    
    // Initializer
    init() {
        // Load the Core ML model
        guard let loadedModel = try? MNISTClassifier(configuration: MLModelConfiguration()) else {
            fatalError("Failed to load Core ML model")
        }
        self.model = loadedModel
    }
    // Make predictions with the model
    // Make predictions with the model
        func predict(image: CGImage) -> Int? {
            do {
                let pixelBuffer = try pixelBuffer(from: image)
                let input = try MNISTClassifierInput(image: pixelBuffer)
                let output = try model.prediction(input: input)
                return Int(output.classLabel)
            } catch {
                print("Error making prediction: \(error)")
                return nil
            }
        }

        // Helper function to convert CGImage to CVPixelBuffer
    private func pixelBuffer(from image: CGImage) throws -> CVPixelBuffer {
        let targetSize = CGSize(width: 28, height: 28)

        guard let resizedImage = image.resize(to: targetSize),
              let normalizedImage = resizeToPixelValues(resizedImage) else {
            throw NSError(domain: "com.example.MyModel", code: 1, userInfo: nil)
        }

        let pixelFormat = kCVPixelFormatType_OneComponent8

        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: kCFBooleanTrue,
            kCVPixelBufferPixelFormatTypeKey as String: pixelFormat
        ]

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(targetSize.width),
                                         Int(targetSize.height),
                                         pixelFormat,
                                         options as CFDictionary,
                                         &pixelBuffer)

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            throw NSError(domain: "com.example.MyModel", code: 1, userInfo: nil)
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                width: CVPixelBufferGetWidth(buffer),
                                height: CVPixelBufferGetHeight(buffer),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: CGColorSpaceCreateDeviceGray(),
                                bitmapInfo: CGImageAlphaInfo.none.rawValue)

        context?.draw(normalizedImage, in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        CVPixelBufferUnlockBaseAddress(buffer, [])

        return buffer
    }

    private func resizeToPixelValues(_ image: CGImage) -> CGImage? {
        let context = CGContext(data: nil,
                                width: image.width,
                                height: image.height,
                                bitsPerComponent: 8,
                                bytesPerRow: 0,
                                space: CGColorSpaceCreateDeviceGray(),
                                bitmapInfo: CGImageAlphaInfo.none.rawValue)

        context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))

        // Normalize pixel values
        guard let normalizedImage = context?.makeImage() else {
            return nil
        }

        return normalizedImage
    }

    
}
extension CGImage {
    func resize(to size: CGSize) -> CGImage? {
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: 0,
                                space: colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: bitmapInfo.rawValue)

        context?.interpolationQuality = .high
        context?.draw(self, in: CGRect(origin: .zero, size: size))

        return context?.makeImage()
    }
}
