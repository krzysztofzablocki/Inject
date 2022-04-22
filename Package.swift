// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Inject",
    platforms: [
            .macOS(.v10_15),
            .iOS(.v13),
            .tvOS(.v13)
        ],
    products: [
        .library(
            name: "Inject",
            targets: ["Inject", "InjectAutoLoader"]
        )
    ],
    
    dependencies: [],
    targets: [
        .target(
            name: "Inject",
            dependencies: [],
            path: "Sources/Inject/"
        ),
        .target(
           name: "InjectAutoLoader",
           dependencies: ["Inject"],
           path: "Sources/InjectAutoLoader/",
           cSettings: [
              .headerSearchPath("Internal"),
           ]
        )
    ]
)
