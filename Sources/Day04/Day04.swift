import Foundation

struct Day04 {
    let input: String

    init(input: String) {
        self.input = input
    }

    /// Part 1: Count rolls of paper that can be accessed by a forklift
    /// A roll can be accessed if there are fewer than 4 rolls in the 8 adjacent positions
    ///
    /// Time Complexity: O(rows * cols) - we visit each cell once and check 8 neighbors
    /// Space Complexity: O(rows * cols) - storing the grid
    func part1() -> Int {
        let grid = parseGrid()
        let rows = grid.count
        guard rows > 0 else { return 0 }
        let cols = grid[0].count

        // 8 directions: up, down, left, right, and 4 diagonals
        let directions = [
            (-1, -1), (-1, 0), (-1, 1),
            (0, -1),           (0, 1),
            (1, -1),  (1, 0),  (1, 1)
        ]

        var accessibleCount = 0

        for row in 0..<rows {
            for col in 0..<cols {
                // Only check positions with paper rolls
                guard grid[row][col] == "@" else { continue }

                // Count adjacent paper rolls
                var adjacentRolls = 0
                for (dr, dc) in directions {
                    let newRow = row + dr
                    let newCol = col + dc

                    // Check bounds
                    if newRow >= 0 && newRow < rows && newCol >= 0 && newCol < cols {
                        if grid[newRow][newCol] == "@" {
                            adjacentRolls += 1
                        }
                    }
                }

                // Accessible if fewer than 4 adjacent rolls
                if adjacentRolls < 4 {
                    accessibleCount += 1
                }
            }
        }

        return accessibleCount
    }

    func part2() -> Int {
        // Part 2: Iteratively remove accessible rolls until none remain accessible
        // Keep removing rolls that have fewer than 4 adjacent rolls
        //
        // Time Complexity: O(k * rows * cols) where k is the number of removal rounds
        // Space Complexity: O(rows * cols) for the grid
        var grid = parseGrid()
        let rows = grid.count
        guard rows > 0 else { return 0 }
        let cols = grid[0].count

        let directions = [
            (-1, -1), (-1, 0), (-1, 1),
            (0, -1),           (0, 1),
            (1, -1),  (1, 0),  (1, 1)
        ]

        var totalRemoved = 0

        while true {
            // Find all accessible rolls in current state
            var toRemove: [(Int, Int)] = []

            for row in 0..<rows {
                for col in 0..<cols {
                    guard grid[row][col] == "@" else { continue }

                    var adjacentRolls = 0
                    for (dr, dc) in directions {
                        let newRow = row + dr
                        let newCol = col + dc

                        if newRow >= 0 && newRow < rows && newCol >= 0 && newCol < cols {
                            if grid[newRow][newCol] == "@" {
                                adjacentRolls += 1
                            }
                        }
                    }

                    if adjacentRolls < 4 {
                        toRemove.append((row, col))
                    }
                }
            }

            // If no rolls can be removed, we're done
            if toRemove.isEmpty {
                break
            }

            // Remove all accessible rolls
            for (row, col) in toRemove {
                grid[row][col] = "."
            }

            totalRemoved += toRemove.count
        }

        return totalRemoved
    }

    private func parseGrid() -> [[Character]] {
        input
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
            .map { Array($0) }
    }
}

@main
struct Main {
    static func main() {
        guard let inputURL = Bundle.module.url(forResource: "input", withExtension: "txt"),
              let input = try? String(contentsOf: inputURL, encoding: .utf8) else {
            print("Error: Could not load input.txt")
            return
        }

        let day = Day04(input: input)

        print("Day 04 - Printing Department")
        print("============================")
        print("Part 1: \(day.part1())")
        print("Part 2: \(day.part2())")
    }
}
