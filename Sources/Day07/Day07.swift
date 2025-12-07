import Foundation

struct Day07 {
    private let grid: [[UInt8]]
    private let width: Int
    private let height: Int
    private let startRow: Int
    private let startCol: Int
    private let hasStart: Bool

    init(input: String) {
        // Split lines while preserving potential empty rows
        var lines = input.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        while let last = lines.last, last.isEmpty { lines.removeLast() }

        self.width = lines.map(\.count).max() ?? 0
        self.height = lines.count

        var grid = [[UInt8]]()
        var startRow = 0
        var startCol = 0
        var foundStart = false

        for (rowIndex, line) in lines.enumerated() {
            // Pad to uniform width with '.' so column indexing stays O(1)
            var row = [UInt8](repeating: 46, count: width) // 46 = '.'
            for (colIndex, char) in line.utf8.enumerated() {
                row[colIndex] = char
                if char == 83 { // 'S'
                    startRow = rowIndex
                    startCol = colIndex
                    foundStart = true
                }
            }
            grid.append(row)
        }

        self.grid = grid
        self.startRow = startRow
        self.startCol = startCol
        self.hasStart = foundStart
    }

    /// Part 1: Count how many times beams split while falling through the manifold.
    ///
    /// **Algorithm Overview:**
    /// We simulate tachyon beams falling downward through the grid row-by-row.
    /// - A beam starts at the 'S' position and travels straight down.
    /// - When a beam encounters a splitter ('^'), it stops and emits two new beams:
    ///   one to the immediate left, one to the immediate right.
    /// - Multiple beams can merge into the same column (we only track presence, not count).
    /// - We count each splitter hit as one "split" event.
    ///
    /// **Data Structure:**
    /// - `beams[col]`: Boolean array where `true` means at least one beam is active at that column.
    /// - This naturally handles beam merging since we only care about presence.
    ///
    /// **Example Trace:**
    /// ```
    /// Row 0: S at col 7         → beams = [......T......]  (T = true at col 7)
    /// Row 1: all dots           → beams = [......T......]  (beam continues down)
    /// Row 2: ^ at col 7         → splits=1, beams = [.....T.T.....]  (split to cols 6,8)
    /// Row 3: all dots           → beams = [.....T.T.....]  (beams continue down)
    /// Row 4: ^ at cols 6,8      → splits=3, beams = [....T.T.T....]  (each splits)
    /// ```
    ///
    /// Time Complexity: O(r × c) where r = rows, c = columns
    /// Space Complexity: O(c) for the beam mask arrays
    func part1() -> Int {
        guard hasStart, width > 0, height > 0 else { return 0 }

        // Initialize beam at the starting column (where 'S' is located)
        var beams = [Bool](repeating: false, count: width)
        if startCol < width { beams[startCol] = true }

        var splits = 0

        // Process each row from just below 'S' to the bottom of the grid
        for row in (startRow + 1)..<height {
            var next = [Bool](repeating: false, count: width)
            let rowData = grid[row]

            // Check each column that has an active beam
            for col in 0..<width where beams[col] {
                let ch = rowData[col]
                if ch == 94 { // '^' = splitter
                    // Beam hits splitter: count it and spawn left/right beams
                    splits += 1
                    if col > 0 { next[col - 1] = true }           // Beam goes left
                    if col + 1 < width { next[col + 1] = true }   // Beam goes right
                } else {
                    // Empty space: beam continues straight down
                    next[col] = true
                }
            }

            beams = next
            // Early exit if no beams remain (all exited grid boundaries)
            if !beams.contains(true) { break }
        }

        return splits
    }

    /// Part 2: Count distinct timelines after quantum tachyon splitting.
    ///
    /// **Algorithm Overview:**
    /// In the "many-worlds" interpretation, each splitter doesn't just split a beam—
    /// it splits TIME itself. A single particle takes BOTH paths, creating parallel timelines.
    /// We need to count how many distinct timelines exist when the particle finishes.
    ///
    /// **Key Insight:**
    /// - Instead of tracking beam presence (bool), we track timeline COUNT per column.
    /// - When N timelines hit a splitter, each timeline forks into 2, so N timelines
    ///   become N left + N right (total 2N, but distributed to two columns).
    /// - When timelines from different paths converge on the same column (no splitter),
    ///   they remain separate timelines but occupy the same position.
    ///
    /// **Data Structure:**
    /// - `timelines[col]`: Integer count of how many timelines have a particle at that column.
    ///
    /// **Example Trace (simplified):**
    /// ```
    /// Start:      timelines = [......1......]  (1 timeline at col 7)
    /// After ^:    timelines = [.....1.1.....]  (splits to 1 left, 1 right = still 2 total)
    /// After ^^:   timelines = [....1.2.1....]  (outer cols get 1 each, middle merges 1+1=2)
    ///                                           Total = 1+2+1 = 4 timelines
    /// ```
    ///
    /// **Why This Works:**
    /// - Each path through the manifold represents one unique timeline.
    /// - A particle hitting N splitters creates 2^N possible paths.
    /// - But paths can converge spatially while remaining distinct timelines.
    /// - By tracking counts, we correctly sum all distinct paths.
    ///
    /// Time Complexity: O(r × c) where r = rows, c = columns
    /// Space Complexity: O(c) for the timeline count arrays
    func part2() -> Int {
        guard hasStart, width > 0, height > 0 else { return 0 }

        // Start with exactly 1 timeline at the starting column
        var timelines = [Int](repeating: 0, count: width)
        if startCol < width { timelines[startCol] = 1 }

        // Process each row from just below 'S' to the bottom
        for row in (startRow + 1)..<height {
            var next = [Int](repeating: 0, count: width)
            let rowData = grid[row]

            // Process each column that has active timelines
            for col in 0..<width where timelines[col] > 0 {
                let ch = rowData[col]
                if ch == 94 { // '^' = splitter
                    // Each timeline forks: one copy goes left, one goes right
                    // If N timelines hit this splitter, N go left AND N go right
                    if col > 0 { next[col - 1] += timelines[col] }
                    if col + 1 < width { next[col + 1] += timelines[col] }
                } else {
                    // Empty space: all timelines at this column continue straight down
                    // Multiple timelines can accumulate at the same column
                    next[col] += timelines[col]
                }
            }

            timelines = next
            // Early exit if no timelines remain
            if timelines.allSatisfy({ $0 == 0 }) { break }
        }

        // Sum all timelines across all columns = total distinct timelines
        return timelines.reduce(0, +)
    }
}

// MARK: - Main Entry Point

@main
struct Main {
    static func main() {
        guard let inputURL = Bundle.module.url(forResource: "input", withExtension: "txt"),
              let input = try? String(contentsOf: inputURL, encoding: .utf8) else {
            print("Error: Could not load input.txt")
            return
        }

        let day = Day07(input: input)

        print("Day 07 - Laboratories")
        print("======================")
        print("Part 1: \(day.part1())")
        print("Part 2: \(day.part2())")
    }
}
