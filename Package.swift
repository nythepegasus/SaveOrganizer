// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SaveOrganizer",
    products: [
        .library(name: "SaveOrganizer", targets: ["SaveOrganizer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
    ],
    targets: [
        .target(name: "SaveOrganizer"),
        .testTarget(name: "SaveOrganizerTests", dependencies: ["SaveOrganizer"]),
        .executableTarget(name: "save-organizer", dependencies: 
            [
                "SaveOrganizer",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
