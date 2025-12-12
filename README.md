# Advent of Code 2025 🎄

Swift solutions for [Advent of Code 2025](https://adventofcode.com/2025)

## Progress

| Day | Title | Part 1 | Part 2 | Solution | Tests |
|-----|-------|--------|--------|----------|-------|
| [01](https://adventofcode.com/2025/day/1) | Dial Rotations | ⭐ | ⭐ | [Day01.swift](Sources/Day01/Day01.swift) | [Tests](Tests/Day01Tests/Day01Tests.swift) |
| [02](https://adventofcode.com/2025/day/2) | Invalid IDs | ⭐ | ⭐ | [Day02.swift](Sources/Day02/Day02.swift) | [Tests](Tests/Day02Tests/Day02Tests.swift) |
| [03](https://adventofcode.com/2025/day/3) | Joltage Banks | ⭐ | ⭐ | [Day03.swift](Sources/Day03/Day03.swift) | [Tests](Tests/Day03Tests/Day03Tests.swift) |
| [04](https://adventofcode.com/2025/day/4) | Paper Roll Forklift | ⭐ | ⭐ | [Day04.swift](Sources/Day04/Day04.swift) | [Tests](Tests/Day04Tests/Day04Tests.swift) |
| [05](https://adventofcode.com/2025/day/5) | Fresh Ingredients | ⭐ | ⭐ | [Day05.swift](Sources/Day05/Day05.swift) | [Tests](Tests/Day05Tests/Day05Tests.swift) |
| [06](https://adventofcode.com/2025/day/6) | Vertical Problems | ⭐ | ⭐ | [Day06.swift](Sources/Day06/Day06.swift) | [Tests](Tests/Day06Tests/Day06Tests.swift) |
| [07](https://adventofcode.com/2025/day/7) | Tachyon Beam Manifold | ⭐ | ⭐ | [Day07.swift](Sources/Day07/Day07.swift) | [Tests](Tests/Day07Tests/Day07Tests.swift) |
| [08](https://adventofcode.com/2025/day/8) | Junction Box Playground | ⭐ | ⭐ | [Day08.swift](Sources/Day08/Day08.swift) | [Tests](Tests/Day08Tests/Day08Tests.swift) |
| [09](https://adventofcode.com/2025/day/9) | Red Tile Rectangles | ⭐ | ⭐ | [Day09.swift](Sources/Day09/Day09.swift) | [Tests](Tests/Day09Tests/Day09Tests.swift) |
| [10](https://adventofcode.com/2025/day/10) | Machine Configuration | ⭐ | ⭐ | [Day10.swift](Sources/Day10/Day10.swift) | [Tests](Tests/Day10Tests/Day10Tests.swift) |
| [11](https://adventofcode.com/2025/day/11) | Reactor Devices | ⭐ | ⭐ | [Day11.swift](Sources/Day11/Day11.swift) | [Tests](Tests/Day11Tests/Day11Tests.swift) |
| [12](https://adventofcode.com/2025/day/12) | Christmas Tree Farm | ⭐ | ⭐ | [Day12.swift](Sources/Day12/Day12.swift) | [Tests](Tests/Day12Tests/Day12Tests.swift) |

## Solutions Overview

### Day 01: Dial Rotations
Navigate a rotational dial with left/right rotations. Count zero crossings and find first repeat position.
- **Part 1**: Count how many times dial points at 0
- **Part 2**: Find first position visited twice
- **Key Concepts**: Modular arithmetic, position tracking

### Day 02: Invalid IDs
Filter out "invalid" badge IDs within numerical ranges.
- **Part 1**: Count valid IDs in each range
- **Part 2**: Count unique valid IDs across all ranges
- **Key Concepts**: Pattern detection (repeated digit sequences), range processing

### Day 03: Joltage Banks
Select digits from number banks to maximize joltage while maintaining order.
- **Part 1**: Maximize joltage for single bank
- **Part 2**: Sum maximum joltages across multiple banks
- **Key Concepts**: Greedy algorithm, digit selection

### Day 04: Paper Roll Forklift
Simulate forklift accessing paper rolls in a warehouse with obstacles.
- **Part 1**: Count initially accessible rolls
- **Part 2**: Count total removable rolls
- **Key Concepts**: BFS/DFS, reachability, simulation

### Day 05: Fresh Ingredients
Count available ingredient IDs based on freshness ranges.
- **Part 1**: Count IDs within fresh ranges
- **Part 2**: Count unique IDs across all fresh ranges
- **Key Concepts**: Range merging, interval processing

### Day 06: Vertical Problems
Solve vertical arithmetic problems where each letter represents a digit.
- **Part 1**: Sum results of all vertical problems
- **Part 2**: Sum results with additional constraints
- **Key Concepts**: Constraint satisfaction, backtracking

### Day 07: Tachyon Beam Manifold
Simulate tachyon beams falling through a grid with splitters.
- **Part 1**: Count beam splits
- **Part 2**: Count beam splits with modified splitting rules
- **Key Concepts**: Grid simulation, beam tracing

### Day 08: Junction Box Playground
Connect junction boxes in 3D space using Union-Find.
- **Part 1**: Count connections when all boxes are in one circuit
- **Part 2**: Minimum distance to disconnect a specific box
- **Key Concepts**: Union-Find (Disjoint Set Union), 3D Manhattan distance

### Day 09: Red Tile Rectangles
Find largest rectangles with red tiles at opposite corners.
- **Part 1**: Simple rectangle area calculation
- **Part 2**: Rectangle must be inside rectilinear polygon
- **Key Concepts**: Computational geometry, ray casting, coordinate compression

### Day 10: Machine Configuration
Configure machines using button presses with GF(2) linear algebra.
- **Part 1**: Minimum button presses for full configuration
- **Part 2**: Minimum presses for joltage configuration
- **Key Concepts**: Linear algebra over GF(2), Gaussian elimination

### Day 11: Reactor Devices
Count paths through a directed graph of devices.
- **Part 1**: Count all paths from "you" to "out"
- **Part 2**: Count paths visiting both "dac" AND "fft"
- **Key Concepts**: DAG path counting, memoization, graph traversal

### Day 12: Christmas Tree Farm
Fit present shapes into regions using backtracking.
- **Part 1**: Count regions that can fit all required presents
- **Part 2**: Narrative conclusion (both stars earned!)
- **Key Concepts**: Constraint satisfaction, backtracking, shape rotation/flipping

## Build & Run

### Prerequisites
- Swift 5.9 or later
- Xcode 15+ (for macOS) or Swift toolchain

### Building
```bash
swift build
```

### Running a Specific Day
```bash
swift run Day01
swift run Day02
# ... etc
```

### Running Tests
```bash
# Run all tests
swift test

# Run tests for a specific day
swift test --filter Day01Tests
```

## Project Structure

```
AdventOfCode2025/
├── Sources/
│   ├── Day01/              # Each day in separate module
│   │   ├── Day01.swift     # Solution implementation
│   │   └── input.txt       # Puzzle input
│   ├── Day02/
│   │   ├── Day02.swift
│   │   └── input.txt
│   └── ...
├── Tests/
│   ├── Day01Tests/
│   │   └── Day01Tests.swift
│   └── ...
└── Package.swift
```

## Notes

- Each solution includes comprehensive documentation with algorithm explanations
- Time and space complexity analysis provided for all solutions
- Example test cases included from puzzle descriptions
- Input files are gitignored (per Advent of Code's Terms of Service)

## License

MIT License - See [LICENSE](LICENSE) for details

---

⭐ **24/24 stars collected** ⭐
