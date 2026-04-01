// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Go2Shell",
    platforms: [.macOS(.v12)],
    targets: [
        .target(
            name: "Go2ShellLib",
            path: "Sources/Go2ShellLib"
        ),
        .executableTarget(
            name: "Go2Shell",
            dependencies: ["Go2ShellLib"],
            path: "Sources/Go2Shell"
        ),
        .testTarget(
            name: "Go2ShellTests",
            dependencies: ["Go2ShellLib"],
            path: "Tests/Go2ShellTests"
        ),
    ]
)
