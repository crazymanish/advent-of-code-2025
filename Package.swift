// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AdventOfCode2025",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Day01",
            dependencies: [],
            path: "Sources/Day01",
            resources: [.process("input.txt")]
        ),
        .testTarget(
            name: "Day01Tests",
            dependencies: ["Day01"],
            path: "Tests/Day01Tests"
        )
    ]
)
