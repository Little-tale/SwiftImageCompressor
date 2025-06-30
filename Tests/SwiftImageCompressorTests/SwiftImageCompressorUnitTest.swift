//
//  SwiftImageCompressorUnitTest.swift
//  SwiftImageCompressor
//
//  Created by Jae hyung Kim on 6/26/25.
//

import XCTest
@testable import SwiftImageCompressor
import UIKit

final class SwiftImageCompressorUnitTest: XCTestCase {
    
    func testResizeImageShouldReduceSize() {
        let makeImage = makeLargeTestImage()
        guard let image = makeImage.image,
             let _ = makeImage.size else {
            XCTFail("Test image could not be created.")
            return
        }
        
        let resized = SwiftImageCompressor.shared.downSample(image, maxDimension: 100)
        
        XCTAssertLessThanOrEqual(resized.size.width, 100)
        XCTAssertLessThanOrEqual(resized.size.height, 100)
    }
    
    func testJPEGCompressionShouldReturnSmallerData() async {
        let makeImage = makeLargeTestImage()
        guard let image = makeImage.image else {
            XCTFail("Test image could not be created.")
            return
        }
        let want = 2.0
        let compressed = await SwiftImageCompressor.shared.onlyCompressImage(image, type: .jpeg, targetMB: want)
        
        if let compressed {
            print("\n want -> \(makeMb(want))\n Compressed IMAGE SIZE ----> ", mbText(compressed.count), "\n")
        }
        
        XCTAssertNotNil(compressed)
        if let data = compressed {
            XCTAssertLessThanOrEqual(Double(data.count) / 1024 / 1024, want)
        }
    }
    
    func testResizeAndCompressFlow() async {
        let makeImage = makeLargeTestImage()
        guard let image = makeImage.image else {
            XCTFail("Test image could not be created.")
            return
        }
        let want = 2.0
        let compressed = await SwiftImageCompressor.shared.resizeAndCompress(
            image,
            type: .jpeg,
            targetMB: want,
            maxDimension: 200
        )
        
        if let compressed {
            print("\n want -> \(makeMb(want))\n Compressed IMAGE SIZE ----> ", mbText(compressed.count), "\n")
        }
        
        XCTAssertNotNil(compressed)
        if let data = compressed {
            XCTAssertLessThanOrEqual(Double(data.count) / 1024 / 1024, want)
        }
    }
    
    /// make Image Result -> 2.9mb Image  With Size
    private func makeLargeTestImage() -> (image: UIImage?, size: Int?) {
        let size = CGSize(width: 6000, height: 6000)
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return (nil,nil) }

        for y in stride(from: 0, to: Int(size.height), by: 100) {
            for x in stride(from: 0, to: Int(size.width), by: 100) {
                let color = UIColor(
                    red: CGFloat.random(in: 0...1),
                    green: CGFloat.random(in: 0...1),
                    blue: CGFloat.random(in: 0...1),
                    alpha: 1
                )
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: x, y: y, width: 100, height: 100))
            }
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var imageSize: Int? = nil
        
        if let data = image?.jpegData(compressionQuality: 1) {
            imageSize = data.count
            print("\n original Image mb Size --->", mbText(data.count), "\n")
        }
        
        return (image, imageSize)
    }

    
    private func mbText(_ count: Int) -> String {
        return String(format: "%.1f", Double(count) / 1024 / 1024)
    }
    
    private func makeMb(_ count: Double) -> Double {
        return Double(count) / 1024 / 1024
    }
    
}
