// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "Zlib",
   products: [
        .library(
            name: "Zlib",
            targets: ["Zlib"]
            )
    ],
    dependencies: [],
    targets: [
        .target(name: "Zlib",
            dependencies: [
                .target(name:"CNIOExtrasZlib"),
            ]
        ),
        .target(
            name: "CNIOExtrasZlib",
            publicHeadersPath: "include",
            linkerSettings: [
                .linkedLibrary("z")
            ]
        ),
        .testTarget(
            name: "ZlibTests",
            dependencies: ["Zlib"]),
    ]
)
