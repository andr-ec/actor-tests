// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-benchmark",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/otp-interop/swift-erlang-actor-system", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "swift-benchmark",
            dependencies: []),
        .testTarget(
            name: "swift-benchmarkTests",
            dependencies: ["swift-benchmark"]),
    ]
)
