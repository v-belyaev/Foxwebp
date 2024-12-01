// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Foxwebp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Foxwebp",
            targets: ["Foxwebp"]
        ),
    ],
    targets: [
        .target(
            name: "Foxwebp",
            dependencies: ["FoxwebpBridge"]
        ),
        .target(
            name: "FoxwebpBridge",
            dependencies: ["WebP", "WebPDemux"],
            publicHeadersPath: "",
            linkerSettings: [
                .linkedLibrary("WebP"),
                .linkedLibrary("WebPDemux")
            ]
        ),
        .binaryTarget(
            name: "WebP",
            path: "Sources/WebP.xcframework"
        ),
        .binaryTarget(
            name: "WebPDemux",
            path: "Sources/WebPDemux.xcframework"
        )
    ]
)
