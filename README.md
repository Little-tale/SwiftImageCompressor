
# SwiftImageCompressor

A lightweight, high-performance Swift library for resizing and compressing `UIImage` to a specific file size (in megabytes).
Supports JPEG and PNG formats, with both synchronous and asynchronous APIs.

---

## ✅ Features

- Resize images to fit within a max dimension while preserving aspect ratio
- Compress images to target file size (JPEG: binary search; PNG: lossless check)
- `UIImage` extensions included for ease of use
- `async/await`, completion handler, and sync APIs
- Written in pure Swift with no dependencies
- Supports iOS 14+

---

## 📦 Installation

### Swift Package Manager (SPM)

Add this to your `Package.swift` dependencies:

```swift
.package(url: "https://github.com/your-username/SwiftImageCompressor.git", from: "0.0.2")
```

Then include it in your target dependencies:

```swift
.target(
    name: "YourApp",
    dependencies: ["SwiftImageCompressor"]
)
```

## Usage

###  Resize and Compress (Async)

```swift
import SwiftImageCompressor
import UIKit

let image = UIImage(named: "largeImage")!

let data = await image.reSizeWithCompressImage(
    type: .jpeg,
    targetMB: 1.5,
    maxDimension: 2048
)

print("Compressed size: \(Double(data?.count ?? 0) / 1024 / 1024) MB")
```

### Completion Handler

```swift
image.resizeAndCompress(type: .jpeg, targetMB: 1.0) { data in
    if let data = data {
        print("Compressed image is \(Double(data.count) / 1024 / 1024) MB")
    }
}
```

### Synchronous

```swift
let data = image.reSizeWithCompressImage(type: .jpeg, targetMB: 2.0)
```

### Resize Only
```swift
let resized = image.resizeImage(maxDimension: 1024)
```

# 📌 PNG Support Notes
> PNG compression is lossless, so **file size cannot be controlled**
> The library will return nil if the **PNG image** still exceeds the size after **resizing**
> For smaller PNGs, just use .png type — no compression quality parameter is used

# 📄 License
MIT License © 2025 Jae hyung Kim

Feel free to contribute or open issues!

