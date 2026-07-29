// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DesktopMascotKit",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "MascotCore", targets: ["MascotCore"]),
        .library(name: "MascotAnimation", targets: ["MascotAnimation"]),
        .library(name: "MascotWindow", targets: ["MascotWindow"]),
    ],
    targets: [
        .target(name: "MascotCore"),
        .target(name: "MascotAnimation", dependencies: ["MascotCore"]),
        .target(name: "MascotWindow", dependencies: ["MascotCore"]),
        .testTarget(name: "MascotCoreTests", dependencies: ["MascotCore"]),
        .testTarget(name: "MascotAnimationTests", dependencies: ["MascotAnimation"]),
        .testTarget(name: "MascotWindowTests", dependencies: ["MascotWindow"]),
    ]
)
