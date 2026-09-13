// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WeTypeReplicaOverlay",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "WeTypeReplicaCore", targets: ["WeTypeReplicaCore"])
    ],
    targets: [
        .target(name: "WeTypeReplicaCore"),
        .testTarget(name: "WeTypeReplicaCoreTests", dependencies: ["WeTypeReplicaCore"])
    ]
)
