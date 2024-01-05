// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "DanmakuKit",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "DanmakuKit", targets: ["DanmakuKit"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "DanmakuKit", dependencies:[])
    ]
)

