// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "swift-zlib",
    products: [
        .library(
            name: "Zlib",
            targets: ["SwiftZLib"]
            )
    ],
    dependencies: [
        .package(url: "https://github.com/the-swift-collective/zlib.git", from: "1.3.1"),
    ],
    targets: [
        .target(name: "SwiftZLib",
            dependencies: [
                .product(name: "ZLib", package: "zlib"),
            ]
        ),
        .testTarget(
            name: "ZlibTests",
            dependencies: ["SwiftZLib"])
    ]
)
