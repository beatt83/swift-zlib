// swift-tools-version: 5.5
import PackageDescription

#if os(Linux) || os(Windows)
let zlibPkgConfig: String? = "zlib"
let zlibProviders: [SystemPackageProvider]? = [
    .apt(["zlib"])
]
#else
let zlibPkgConfig: String? = nil
let zlibProviders: [SystemPackageProvider]? = nil
#endif

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
               pkgConfig: zlibPkgConfig,
               providers: zlibProviders
        ),
        .testTarget(
            name: "ZlibTests",
            dependencies: ["ZlibSwift"]),
    ]
)
