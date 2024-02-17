// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XMLViewerUI",
    platforms: [.macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "XMLViewerUI",
            targets: ["XMLViewerUI"]),
    ],
    dependencies: [
//        .package(path: "/Volumes/Repositories/Private/Personal/Library/Multi/UIFoundation"),
        .package(url: "https://github.com/Mx-Iris/UIFoundation", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "XMLViewerUI",
            dependencies: [
                .product(name: "UIFoundation", package: "UIFoundation"),
                .product(name: "UIFoundationToolbox", package: "UIFoundation")
            ]
        ),
        .testTarget(
            name: "XMLViewerUITests",
            dependencies: ["XMLViewerUI"]),
    ]
)
