// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Inject",
    platforms: [
            .macOS(.v10_15),
            .iOS(.v13),
            .tvOS(.v13),
            .watchOS(.v6)
        ],
    products: [
        .library(
            name: "Inject",
            targets: ["Inject"]),
    ],
    
    dependencies: [
    ],
    targets: [
        .target(
            name: "Inject",
            dependencies: []),
    ]
)
