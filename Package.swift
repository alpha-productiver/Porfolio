// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AussiePortfolio",
    platforms: [
        .iOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.45.0")
    ],
    targets: [
        .target(
            name: "AussiePortfolio",
            dependencies: [
                .product(name: "RealmSwift", package: "realm-swift")
            ]
        )
    ]
)