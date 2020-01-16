// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageViewer",
    platforms: [.iOS(.v8)],
    products: [
        .library(name: "ImageViewer", targets: ["ImageViewer"]),
    ],
    targets: [
        .target(name: "ImageViewer", dependencies: [])
    ]
)
