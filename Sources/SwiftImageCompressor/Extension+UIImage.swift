//
//  Extension+UIImage.swift
//  SwiftImageCompressor
//
//  Created by Jae hyung Kim on 6/30/25.
//

import UIKit

extension UIImage {
    /// Resize and Compress to target MB
    /// - Parameters:
    ///   - type: ImageType (jpeg, png)
    ///   - targetMB: target size in MB
    ///   - maxDimension: optional max dimension (default: 2048)
    /// - Returns: Compressed Data?
    public func reSizeWithCompressImage(
        type: ImageType,
        targetMB: Double,
        maxDimension: CGFloat = 2048
    ) -> Data? {
        return SwiftImageCompressor.shared.resizeAndCompress(self, type: type, targetMB: targetMB, maxDimension: maxDimension)
    }
    
    /// Resize and Compress to target MB
    /// - Parameters:
    ///   - type: ImageType (jpeg, png)
    ///   - targetMB: target size in MB
    ///   - maxDimension: optional max dimension (default: 2048)
    /// - Returns: Compressed Data?
    public func reSizeWithCompressImage(
        type: ImageType,
        targetMB: Double,
        maxDimension: CGFloat = 2048
    ) async -> Data? {
        return await SwiftImageCompressor.shared.resizeAndCompress(self, type: type, targetMB: targetMB, maxDimension: maxDimension)
    }
    
    /// Resize and Compress to target MB
    /// - Parameters:
    ///   - type: ImageType (jpeg, png)
    ///   - targetMB: target size in MB
    ///   - maxDimension: optional max dimension (default: 2048)
    ///   - completion: Compressed Data?
    public func reSizeWithCompressImage(
        type: ImageType,
        targetMB: Double,
        maxDimension: CGFloat = 2048,
        completion: @Sendable @escaping (Data?) -> Void
    ) {
        SwiftImageCompressor.shared.resizeAndCompress(self, type: type, targetMB: targetMB, maxDimension: maxDimension, completion: completion)
    }
    
    /// Resizing Image func
    /// - Parameters:
    ///   - maxDimension: ex) 2048 -> 2048x2048
    /// - Returns: UIImage
    public func resizeImage(maxDimension: CGFloat = 2048) -> UIImage {
        return SwiftImageCompressor.shared.downSample(self, maxDimension: maxDimension)
    }
    
    /// Compress the given image directly without resizing, targeting a specified file size in MB.
    /// This function keeps the original image dimensions but compresses it to meet the desired size.
    /// - Parameters:
    ///   - type: The desired image format (`jpeg` or `png`).
    ///   - targetMB: The maximum allowed file size in megabytes.
    /// - Returns: The compressed image data (`Data?`), or `nil` if compression fails.
    public func onlyCompressImage(type: ImageType, targetMB: Double) async -> Data? {
        return await SwiftImageCompressor.shared.onlyCompressImage(self, type: type, targetMB: targetMB)
    }
    
    /// Compress the given image directly without resizing, targeting a specified file size in MB.
    /// This function keeps the original image dimensions but compresses it to meet the desired size.
    /// - Parameters:
    ///   - type: The desired image format (`jpeg` or `png`).
    ///   - targetMB: The maximum allowed file size in megabytes.
    ///   - completion: The compressed image data (`Data?`), or `nil` if compression fails.
    public func onlyCompressImage(
        type: ImageType,
        targetMB: Double,
        completion: @Sendable @escaping (Data?) -> Void
    ) {
        SwiftImageCompressor.shared.onlyCompressImage(self, type: type, targetMB: targetMB, completion: completion)
    }
}
