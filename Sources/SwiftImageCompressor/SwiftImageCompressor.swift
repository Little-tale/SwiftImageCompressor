//
//  SwiftImageCompressor.swift
//  SwiftImageCompressor
//
//  Created by Jae hyung Kim on 6/26/25.
//

import UIKit
import ImageIO

public final class SwiftImageCompressor: Sendable {
    
    private init() {}
    
    /// Resize and Compress to target MB
    /// - Parameters:
    ///   - image: UIImage to compress
    ///   - type: ImageType (jpeg, png)
    ///   - targetMB: target size in MB
    ///   - maxDimension: optional max dimension (default: 2048)
    /// - Returns: Compressed Data?
    public func resizeAndCompress(
        _ image: UIImage,
        type: ImageType,
        targetMB: Double,
        maxDimension: CGFloat = 2048
    ) -> Data? {
        let resized = downSample(image, maxDimension: maxDimension)
        
        switch type {
        case .jpeg:
            return compressionJPEGEngine(from: resized, mbSize: targetMB)
        case .png:
            return compressionPNGEngine(from: resized, mbSize: targetMB)
        }
    }
    
    
    /// Resize and Compress to target MB
    /// - Parameters:
    ///   - image: UIImage to compress
    ///   - type: ImageType (jpeg, png)
    ///   - targetMB: target size in MB
    ///   - maxDimension: optional max dimension (default: 2048)
    ///   - completion: Compressed Data?
    public func resizeAndCompress(
        _ image: UIImage,
        type: ImageType,
        targetMB: Double,
        maxDimension: CGFloat = 2048,
        completion: @Sendable @escaping (Data?) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            let resized = self.downSample(image, maxDimension: maxDimension)
            let result: Data?

            switch type {
            case .jpeg:
                result = self.compressionJPEGEngine(from: resized, mbSize: targetMB)
            case .png:
                result = self.compressionPNGEngine(from: resized, mbSize: targetMB)
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    /// Resize and Compress to target MB
    /// - Parameters:
    ///   - image: UIImage to compress
    ///   - type: ImageType (jpeg, png)
    ///   - targetMB: target size in MB
    ///   - maxDimension: optional max dimension (default: 2048)
    /// - Returns: Compressed Data?
    public func resizeAndCompress(
        _ image: UIImage,
        type: ImageType,
        targetMB: Double,
        maxDimension: CGFloat = 2048
    ) async -> Data? {
        await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return nil }
            let resized = downSample(image, maxDimension: maxDimension)
            
            switch type {
            case .jpeg:
                return compressionJPEGEngine(from: resized, mbSize: targetMB)
            case .png:
                return compressionPNGEngine(from: resized, mbSize: targetMB)
            }
        }.value
    }
}

// MARK: Singletone
extension SwiftImageCompressor {
    public static let shared = SwiftImageCompressor()
}

// MARK: Resize
extension SwiftImageCompressor {
    /// Resizing Image func
    /// - Parameters:
    ///   - image: UIImage
    ///   - maxDimension: ex) 2048 -> 2048x2048
    /// - Returns: UIImage
    @available(*, message: "This Function Will Be Deprecated Soon Use downsampling function")
    public func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let width = image.size.width
        let height = image.size.height
        
        guard width > maxDimension || height > maxDimension else {
            return image
        }
        
        let aspectRatio: CGFloat = width / height
        var newSize: CGSize
        
        // Vertical
        if aspectRatio > 1 {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        }
        // Horizontal
        else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

// MARK: DownSample
extension SwiftImageCompressor {
    
    /// DownSample Func
    /// - Parameters:
    ///   - image: original Image
    ///   - maxDimension: 2048x 2048 -> 2048
    /// - Returns: DownSample Image or Fail To OriginalImage
    func downSample(_ image: UIImage, maxDimension: CGFloat = 2048) -> UIImage {
        guard let data = image.pngData() else {
            print("Image Data Error")
            return image
        }
        
        let cfData = data as CFData
        
        guard let imageSource = CGImageSourceCreateWithData(cfData, nil) else {
            print("Image Source Fail")
            return image
        }
        
        let maxPixel = maxDimension
        
        let options = [
            kCGImageSourceThumbnailMaxPixelSize: maxPixel,
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ] as CFDictionary
        
        guard let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options) else {
            print("Downsample Failed")
            return image
        }
        
        return UIImage(cgImage: scaledImage)
    }

}

// MARK: Compresse
extension SwiftImageCompressor {
    /// binary search Image Compress
    /// - Parameters:
    ///   - from: UIImage
    ///   - mbSize: you want mb Size ... ex) 50mb -> 50
    /// - Returns: Data?
    public func compressionJPEGEngine(from: UIImage, mbSize: Double) -> Data? {
        var low: CGFloat = 0
        var high: CGFloat = 1
        let minQuality: CGFloat = 0.1
        var bestData: Data? = nil
        
        
        bestData = from.jpegData(compressionQuality: 1)
        if let bestData {
            let calc = calcMBSize(of: bestData)
            if calc <= mbSize {
                print("already best")
                return bestData
            }
        }
        
        autoreleasepool {
            while high - low > 0.05 && high > minQuality {
                let mid = (low + high) / 2
                guard let data = from.jpegData(compressionQuality: mid) else {
                    break
                }
                
                let sizeMB = calcMBSize(of: data)
                // ex) 150mb > 100mb
                if sizeMB > mbSize {
                    print("Not !!!")
                    high = mid
                } else {
                    bestData = data
                    print("BEST !!!")
                    low = mid
                }
            }
            print("결말")
        }
        
        return bestData
    }
    
    /// compress Png
    /// It is a lossless compression method, so the capacity cannot be adjusted.
    /// - Parameters:
    ///   - from: UIImage
    ///   - mbSize: max mb Size
    /// - Returns: png Data?
    public func compressionPNGEngine(from: UIImage, mbSize: Double) -> Data? {
        guard let pngData = from.pngData() else {
            return nil
        }
        let sizeMB = calcMBSize(of: pngData)
        return sizeMB <= mbSize ? pngData : nil
    }
    
    private func calcMBSize(of data: Data) -> Double {
        return Double(data.count) / 1024 / 1024
    }
}


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
    public func resizeAndCompress(
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
        return SwiftImageCompressor.shared.resizeImage(self, maxDimension: maxDimension)
    }
    
}

fileprivate final class TestUIImage: UIImage {
    deinit {
        print("DEAD")
    }
}
