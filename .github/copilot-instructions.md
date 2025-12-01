# Copilot Instructions for Advent of Code 2025

## Project Overview
Swift-based solutions for [Advent of Code 2025](https://adventofcode.com/2025). Each day's puzzle has two parts with shared input.

## Project Structure
```
AdventOfCode2025/
├── Sources/
│   ├── Day01/          # Each day in separate module
│   │   ├── Day01.swift # Solution implementation
│   │   └── input.txt   # Puzzle input (DO NOT commit to public repos)
│   └── Utilities/      # Shared helpers (parsing, grid, etc.)
├── Tests/              # Unit tests per day
└── Package.swift
```

## Solution Pattern
Each day should follow this structure:
```swift
struct Day01 {
    let input: String

    func part1() -> Int {
        // Parse input and solve part 1
    }

    func part2() -> Int {
        // Parse input and solve part 2
    }
}
```

## Common Patterns
- **Input parsing**: Read from `input.txt`, split by newlines with `.components(separatedBy: "\n")`
- **Grid problems**: Use `[[Character]]` or custom `Point` struct with `x, y` coordinates
- **Graph traversal**: BFS with `Set<State>` for visited tracking, use `Deque` for queue
- **Memoization**: Use `@MainActor` dictionary cache or pass cache as inout parameter

## Build & Run
```bash
swift build           # Build project
swift run Day01       # Run specific day
swift test            # Run all tests
```

## Conventions
- Keep solutions self-contained per day; extract to `Utilities/` only when reused 3+ times
- Prefer `Int` over other numeric types unless puzzle requires otherwise
- Use descriptive variable names even for quick solutions
- Add example test cases from puzzle descriptions before solving with real input
- **Always analyze and document Time & Space Complexity** for each solution (both parts)

## Input Handling
- Store puzzle input in `input.txt` per day directory
- Never commit personal puzzle inputs to public repositories (AoC ToS)
- Parse lazily if input is large; use `String.SubSequence` to avoid copies
