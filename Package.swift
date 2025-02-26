// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kiwi",
    platforms: [.iOS(.v11)],
    products: [.library(name: "Kiwi", type: .static, targets: ["Kiwi"])],
    targets: [.target(name: "Kiwi", path: "./Kiwi")]
)
