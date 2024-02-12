// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUINavigation",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "SwiftUINavigation",
            targets: ["SwiftUINavigation"]),
    ],
    targets: [
        .target(name: "SwiftUINavigation",
                path: "Sources"
        )
    ]
)
