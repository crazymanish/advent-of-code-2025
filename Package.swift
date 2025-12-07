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
        .executableTarget(
            name: "Day04",
            dependencies: [],
            path: "Sources/Day04",
            resources: [.process("input.txt")]
        ),
        .executableTarget(
            name: "Day05",
            dependencies: [],
            path: "Sources/Day05",
            resources: [.process("input.txt")]
        ),
        .executableTarget(
            name: "Day06",
            dependencies: [],
            path: "Sources/Day06",
            resources: [.process("input.txt")]
        ),
        .executableTarget(
            name: "Day07",
            dependencies: [],
            path: "Sources/Day07",
            resources: [.process("input.txt")]
        ),
        .executableTarget(
            name: "Day08",
            dependencies: [],
            path: "Sources/Day08",
            resources: [.process("input.txt")]
        ),
        .executableTarget(
            name: "Day09",
            dependencies: [],
            path: "Sources/Day09",
            resources: [.process("input.txt")]
        ),
        .executableTarget(
            name: "Day10",
            dependencies: [],
            path: "Sources/Day10",
            resources: [.process("input.txt")]
        ),
        .executableTarget(
            name: "Day11",
            dependencies: [],
            path: "Sources/Day11",
            resources: [.process("input.txt")]
        ),
        .executableTarget(
            name: "Day12",
            dependencies: [],
            path: "Sources/Day12",
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
        ),
        .testTarget(
            name: "Day04Tests",
            dependencies: ["Day04"],
            path: "Tests/Day04Tests"
        ),
        .testTarget(
            name: "Day05Tests",
            dependencies: ["Day05"],
            path: "Tests/Day05Tests"
        ),
        .testTarget(
            name: "Day06Tests",
            dependencies: ["Day06"],
            path: "Tests/Day06Tests"
        ),
        .testTarget(
            name: "Day07Tests",
            dependencies: ["Day07"],
            path: "Tests/Day07Tests"
        ),
        .testTarget(
            name: "Day08Tests",
            dependencies: ["Day08"],
            path: "Tests/Day08Tests"
        ),
        .testTarget(
            name: "Day09Tests",
            dependencies: ["Day09"],
            path: "Tests/Day09Tests"
        ),
        .testTarget(
            name: "Day10Tests",
            dependencies: ["Day10"],
            path: "Tests/Day10Tests"
        ),
        .testTarget(
            name: "Day11Tests",
            dependencies: ["Day11"],
            path: "Tests/Day11Tests"
        ),
        .testTarget(
            name: "Day12Tests",
            dependencies: ["Day12"],
            path: "Tests/Day12Tests"
        )
    ]
)
