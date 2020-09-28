// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ShellRunner",
    products: [
        .library(name: "ShellRunner", targets: ["ShellRunner"]),
    ],
    targets: [
        .target(name: "ShellRunner", path: "Sources"),
        .testTarget(name: "ShellRunnerTests", dependencies: ["ShellRunner"]),
    ]
)
