// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Constraints",
    defaultLocalization: "en",
    platforms: [.iOS(.v9), .macOS(.v10_14), .tvOS(.v11), .watchOS(.v3)],
    products: [.library(name: "Constraints", targets: ["Constraints"])],
    dependencies: [],
    targets: [.target(name: "Constraints")]
)
