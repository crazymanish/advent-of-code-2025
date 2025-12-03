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
        .executableTarget(
            name: "Day02",
            dependencies: [],
            path: "Sources/Day02",
            resources: [.process("input.txt")]
        ),
        .executableTarget(
            name: "Day03",
            dependencies: [],
            path: "Sources/Day03",
            resources: [.process("input.txt")]
        ),
        .testTarget(
            name: "Day01Tests",
            dependencies: ["Day01"],
            path: "Tests/Day01Tests"
        ),
        .testTarget(
            name: "Day02Tests",
            dependencies: ["Day02"],
            path: "Tests/Day02Tests"
        ),
        .testTarget(
            name: "Day03Tests",
            dependencies: ["Day03"],
            path: "Tests/Day03Tests"
        )
    ]
)
