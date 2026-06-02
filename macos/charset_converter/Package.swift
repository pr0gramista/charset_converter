// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "charset_converter",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "charset-converter", targets: ["charset_converter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "charset_converter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: []
        )
    ]
)
