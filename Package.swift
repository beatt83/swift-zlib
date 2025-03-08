// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "Zlib",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .macCatalyst(.v14),
        .tvOS(.v14),
        .watchOS(.v5)
    ],
   products: [
        .library(
            name: "Zlib",
            targets: ["ZlibSwift"]
            )
    ],
    dependencies: [],
    targets: [
        .target(name: "ZlibShims", dependencies: ["Zlib"]),
        .target(name: "ZlibSwift",
            dependencies: [
                .target(name:"ZlibShims"),
            ]
        ),
        .systemLibrary(
               name: "Zlib",
               pkgConfig: "zlib",
               providers: [
                    .apt(["zlib"]),
                    .brew(["zlib"]),
                ]),
        .testTarget(
            name: "ZlibTests",
            dependencies: ["ZlibSwift"]),
    ]
)
