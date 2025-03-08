# Zlib

🗜 A tiny Swift extension to decompress Zlib data, this implementation is based on `CNIOExtrasZlib` in [swift-nio-extras](https://github.com/apple/swift-nio-extras) .

```swift
import Zlib

// Zlib uses RFC 1951
// Decompressed data
print(data.zlibDecompressed)

// Compressed data
print(data.zlibCompressed.string)

// Apple compress and decompress use RFC1950 and doesnt support RFC1951
// Decompressed data
print(data.deflateDecompressed)

// Compressed data
print(data.deflateCompressed.string)
```


