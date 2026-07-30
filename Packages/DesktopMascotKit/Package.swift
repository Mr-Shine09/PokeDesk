// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DesktopMascotKit",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "MascotCore", targets: ["MascotCore"]),
        .library(name: "MascotAnimation", targets: ["MascotAnimation"]),
        .library(name: "MascotWindow", targets: ["MascotWindow"]),
        .library(name: "MascotTransport", targets: ["MascotTransport"]),
        .executable(name: "dockpet-event", targets: ["dockpet-event"]),
    ],
    targets: [
        .target(name: "MascotCore"),
        .target(name: "MascotAnimation", dependencies: ["MascotCore"]),
        .target(name: "MascotWindow", dependencies: ["MascotCore"]),
        .target(name: "MascotTransport", dependencies: ["MascotCore"]),
        .executableTarget(name: "dockpet-event", dependencies: ["MascotCore", "MascotTransport"]),
        .testTarget(name: "MascotCoreTests", dependencies: ["MascotCore"]),
        .testTarget(name: "MascotAnimationTests", dependencies: ["MascotAnimation"]),
        .testTarget(name: "MascotWindowTests", dependencies: ["MascotWindow"]),
        .testTarget(name: "MascotTransportTests", dependencies: ["MascotTransport"]),
    ]
)
