// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MultiSlider",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(name: "MultiSlider", targets: ["MultiSlider"]),
    ],
    targets: [
        .target(name: "MultiSlider", dependencies: ["SweeterSwift", "AvailableHapticFeedback"], path: "Sources"),
    ],
    swiftLanguageVersions: [.v5]
)
