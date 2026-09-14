// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WeTypeReplicaOverlay",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "WeTypeReplicaCore", targets: ["WeixinRebuild"])
    ],
    targets: [
        .target(
            name: "WeixinRebuild",
            path: "Sources/WeTypeReplicaCore"
        ),
        .testTarget(
            name: "WeTypeReplicaCoreTests",
            dependencies: ["WeixinRebuild"],
            path: "Tests"
        )
    ]
)
