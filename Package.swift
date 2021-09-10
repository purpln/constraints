// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Constraints",
    platforms: [.iOS(.v10)],
    products: [.library(name: "Constraints", targets: ["Constraints"])],
    dependencies: [],
    targets: [.target(name: "Constraints")]
)
