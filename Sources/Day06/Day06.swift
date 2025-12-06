import Foundation

struct Day06 {
    let input: String

    init(input: String) {
        self.input = input
    }

    /// Part 1: Solve each vertical problem and sum all results.
    ///
    /// Input format example:
    /// ```
    ///    12   9
    ///   341  85
    ///     7   2
    /// *     +
    /// ```
    /// Each problem is a vertical slice separated by space columns.
    /// Numbers are read row-wise (left-to-right per row).
    /// Problem 1: 12 × 341 × 7 = 28644
    /// Problem 2: 9 + 85 + 2 = 96
    /// Grand total = 28644 + 96 = 28740
    ///
    /// Time Complexity: O(r * c) where r is rows and c is columns
    /// Space Complexity: O(r * c) for the grid representation
    func part1() -> Int {
        guard let worksheet = buildWorksheet() else { return 0 }
        return evaluateProblems(worksheet: worksheet, columnar: false)
    }

    /// Part 2: Solve each problem when numbers are read column-wise.
    ///
    /// Same input, but each COLUMN forms a number (top-to-bottom, top digit most significant).
    /// ```
    ///    12   9
    ///   341  85
    ///     7   2
    /// *     +
    /// ```
    /// Problem 1 columns: 3, 14, 217 → 3 × 14 × 217 = 9114
    /// Problem 2 columns: 8, 952 → 8 + 952 = 960
    /// Grand total = 9114 + 960 = 10074
    ///
    /// Time Complexity: O(r * c)
    /// Space Complexity: O(r * c)
    func part2() -> Int {
        guard let worksheet = buildWorksheet() else { return 0 }
        return evaluateProblems(worksheet: worksheet, columnar: true)
    }

    // MARK: - Data Structures

    /// Represents the parsed worksheet with O(1) character access
    private struct Worksheet {
        let grid: [[UInt8]]                    // ASCII grid (space=32, '0'=48, '*'=42, '+'=43)
        let width: Int                          // Total columns in the grid
        let height: Int                         // Total rows in the grid
        let operatorRow: Int                    // Index of the bottom row containing operators
        let slices: [(start: Int, end: Int)]   // Column ranges for each problem
    }

    // MARK: - Parsing

    /// Builds the worksheet by:
    /// 1. Splitting input into lines and padding to uniform width
    /// 2. Converting to ASCII grid for O(1) random access
    /// 3. Finding separator columns (all spaces) to identify problem boundaries
    /// 4. Extracting column ranges (slices) for each problem
    private func buildWorksheet() -> Worksheet? {
        // Split input into lines, preserving empty lines
        var lines = input.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }

        // Remove trailing empty lines
        while let last = lines.last, last.isEmpty { lines.removeLast() }

        // Need at least 2 lines (one for numbers, one for operators)
        guard lines.count >= 2 else { return nil }

        let width = lines.map(\.count).max() ?? 0
        let height = lines.count

        // Build ASCII grid with space (32) padding for O(1) random access
        // This avoids expensive String.index(_:offsetBy:) calls later
        var grid = [[UInt8]](repeating: [UInt8](repeating: 32, count: width), count: height)
        for (row, line) in lines.enumerated() {
            for (col, char) in line.utf8.enumerated() {
                grid[row][col] = char
            }
        }

        // Find separator columns: columns that contain ONLY spaces
        // These separate individual math problems from each other
        var separator = [Bool](repeating: true, count: width)
        for col in 0..<width {
            for row in 0..<height {
                if grid[row][col] != 32 {  // 32 = ASCII space
                    separator[col] = false
                    break
                }
            }
        }

        // Extract problem slices: contiguous ranges of non-separator columns
        // Each slice represents one vertical math problem
        var slices: [(Int, Int)] = []
        var col = 0
        while col < width {
            // Skip separator columns
            if separator[col] { col += 1; continue }

            // Found start of a problem, find where it ends
            let start = col
            while col < width && !separator[col] { col += 1 }
            slices.append((start, col - 1))
        }

        return Worksheet(grid: grid, width: width, height: height, operatorRow: height - 1, slices: slices)
    }

    // MARK: - Evaluation

    /// Evaluates all problems in the worksheet and returns the grand total.
    ///
    /// - Parameter columnar: If false (Part 1), each row forms a number.
    ///                       If true (Part 2), each column forms a number.
    private func evaluateProblems(worksheet: Worksheet, columnar: Bool) -> Int {
        var total = 0

        // Process each problem slice
        for (start, end) in worksheet.slices {

            // Step 1: Find the operator in the bottom row of this slice
            // Scan for '+' (ASCII 43) or '*' (ASCII 42)
            var operation: UInt8 = 0
            for col in start...end {
                let ch = worksheet.grid[worksheet.operatorRow][col]
                if ch == 42 || ch == 43 {  // '*' = 42, '+' = 43
                    operation = ch
                    break
                }
            }
            guard operation != 0 else { continue }

            // Step 2: Initialize result based on operation
            // For multiplication, start with 1 (identity element)
            // For addition, start with 0 (identity element)
            let isMultiply = (operation == 42)
            var result = isMultiply ? 1 : 0

            // Step 3: Parse numbers based on reading direction
            if columnar {
                // Part 2: Each COLUMN forms a number
                // Read digits top-to-bottom, top digit is most significant
                // Example: column with '1', '4', '7' → 147
                for col in start...end {
                    var num = 0
                    var hasDigit = false

                    // Scan column from top to bottom (excluding operator row)
                    for row in 0..<worksheet.operatorRow {
                        let ch = worksheet.grid[row][col]
                        if ch >= 48 && ch <= 57 {  // '0'=48 to '9'=57
                            // Build number: shift existing digits left, add new digit
                            num = num * 10 + Int(ch - 48)
                            hasDigit = true
                        }
                        // Skip spaces - they don't contribute to the number
                    }

                    // Only include columns that had at least one digit
                    if hasDigit {
                        result = isMultiply ? result * num : result + num
                    }
                }
            } else {
                // Part 1: Each ROW forms a number
                // Read digits left-to-right within the slice
                // Example: row with ' ', '1', '2' → 12
                for row in 0..<worksheet.operatorRow {
                    var num = 0
                    var hasDigit = false

                    // Scan row from left to right within slice bounds
                    for col in start...end {
                        let ch = worksheet.grid[row][col]
                        if ch >= 48 && ch <= 57 {  // '0'=48 to '9'=57
                            // Build number: shift existing digits left, add new digit
                            num = num * 10 + Int(ch - 48)
                            hasDigit = true
                        }
                        // Skip spaces - they don't contribute to the number
                    }

                    // Only include rows that had at least one digit
                    if hasDigit {
                        result = isMultiply ? result * num : result + num
                    }
                }
            }

            // Step 4: Add this problem's result to the grand total
            total += result
        }

        return total
    }
}

// MARK: - Main Entry Point

@main
struct Main {
    static func main() {
        // Load puzzle input from bundled resource
        guard let inputURL = Bundle.module.url(forResource: "input", withExtension: "txt"),
              let input = try? String(contentsOf: inputURL, encoding: .utf8) else {
            print("Error: Could not load input.txt")
            return
        }

        let day = Day06(input: input)

        print("Day 06 - Trash Compactor")
        print("========================")
        print("Part 1: \(day.part1())")
        print("Part 2: \(day.part2())")
    }
}
