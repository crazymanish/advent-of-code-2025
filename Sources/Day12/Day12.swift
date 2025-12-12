import Foundation

/// Represents a present shape that needs to fit in a region.
/// Shapes are defined by their occupied cells relative to origin (0,0).
struct Shape {
    /// Occupied cells as (x, y) tuples - stored as array for fast iteration
    let cells: [(x: Int, y: Int)]

    /// Bounding box dimensions of this shape
    let width: Int
    let height: Int

    /// Total number of occupied cells in this shape
    let cellCount: Int

    init(cells: Set<Point>) {
        // Normalize to ensure shape starts at origin (0,0)
        let normalized = Shape.normalize(cells)
        self.cells = normalized.map { ($0.x, $0.y) }

        // Calculate bounding box
        self.width = (normalized.map { $0.x }.max() ?? 0) + 1
        self.height = (normalized.map { $0.y }.max() ?? 0) + 1
        self.cellCount = normalized.count
    }

    /// Normalize shape coordinates so minimum x and y are both 0
    private static func normalize(_ points: Set<Point>) -> Set<Point> {
        let minX = points.map { $0.x }.min()!
        let minY = points.map { $0.y }.min()!
        return Set(points.map { Point(x: $0.x - minX, y: $0.y - minY) })
    }

    /// Generate all unique rotations and flips of this shape (up to 8 variants).
    /// This allows shapes to be placed in any orientation to fit the region.
    func allVariants() -> [Shape] {
        var uniqueVariants: [Set<Point>] = []
        var currentOrientation = Set(cells.map { Point(x: $0.x, y: $0.y) })

        // Try 4 rotations (0°, 90°, 180°, 270°)
        for _ in 0..<4 {
            let normalized = Shape.normalize(currentOrientation)
            if !uniqueVariants.contains(normalized) {
                uniqueVariants.append(normalized)
            }
            currentOrientation = rotate90Clockwise(currentOrientation)
        }

        // Try horizontal flip followed by 4 more rotations
        currentOrientation = flipHorizontal(Set(cells.map { Point(x: $0.x, y: $0.y) }))
        for _ in 0..<4 {
            let normalized = Shape.normalize(currentOrientation)
            if !uniqueVariants.contains(normalized) {
                uniqueVariants.append(normalized)
            }
            currentOrientation = rotate90Clockwise(currentOrientation)
        }

        return uniqueVariants.map { Shape(cells: $0) }
    }

    /// Rotate points 90 degrees clockwise: (x, y) -> (y, -x)
    private func rotate90Clockwise(_ points: Set<Point>) -> Set<Point> {
        Set(points.map { Point(x: $0.y, y: -$0.x) })
    }

    /// Flip points horizontally: (x, y) -> (-x, y)
    private func flipHorizontal(_ points: Set<Point>) -> Set<Point> {
        Set(points.map { Point(x: -$0.x, y: $0.y) })
    }
}

struct Point: Hashable {
    let x: Int
    let y: Int
}

/// Represents a region under a Christmas tree where presents need to be placed
struct Region {
    let width: Int
    let height: Int
    /// Number of presents needed for each shape index (index = shape ID)
    let presentCounts: [Int]
}

struct Day12 {
    let input: String

    init(input: String) {
        self.input = input
    }

    /// Parse input into shape definitions and region requirements
    private func parse() -> (shapes: [Shape], regions: [Region]) {
        let sections = input.components(separatedBy: "\n\n")

        // Parse shape definitions from the first section
        var shapes: [Shape] = []
        var sectionIndex = 0

        while sectionIndex < sections.count {
            let section = sections[sectionIndex].trimmingCharacters(in: .whitespacesAndNewlines)

            // Shape sections have format "N:\n###\n##.\n..."
            if section.contains(":") && section.contains("#") {
                let lines = section.components(separatedBy: "\n")
                var occupiedCells: Set<Point> = []

                // Skip first line (shape index), parse grid
                for (row, line) in lines.dropFirst().enumerated() {
                    for (col, char) in line.enumerated() {
                        if char == "#" {
                            occupiedCells.insert(Point(x: col, y: row))
                        }
                    }
                }
                shapes.append(Shape(cells: occupiedCells))
            } else {
                // No more shape definitions
                break
            }
            sectionIndex += 1
        }

        // Parse region requirements from remaining sections
        var regions: [Region] = []
        for j in sectionIndex..<sections.count {
            let lines = sections[j].components(separatedBy: "\n")
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty { continue }
                if let region = parseRegionLine(trimmed) {
                    regions.append(region)
                }
            }
        }

        return (shapes, regions)
    }

    /// Parse a single region line: "41x48: 47 27 36 34 31 32"
    /// Format: <width>x<height>: <count0> <count1> ... <countN>
    private func parseRegionLine(_ line: String) -> Region? {
        let parts = line.components(separatedBy: ":")
        guard parts.count == 2 else { return nil }

        let dimensionPart = parts[0].trimmingCharacters(in: .whitespaces)
        let countsPart = parts[1].trimmingCharacters(in: .whitespaces)

        let dimensions = dimensionPart.components(separatedBy: "x")
        guard dimensions.count == 2,
              let width = Int(dimensions[0]),
              let height = Int(dimensions[1]) else { return nil }

        let counts = countsPart.components(separatedBy: " ").compactMap { Int($0) }

        return Region(width: width, height: height, presentCounts: counts)
    }

    /// Part 1: Count how many regions can fit all their required presents
    ///
    /// **Algorithm**: Constraint Satisfaction with Backtracking
    /// - For each region, attempt to place all required presents using backtracking
    /// - Presents can be rotated/flipped (up to 8 orientations per shape)
    /// - Shapes cannot overlap, but empty cells are allowed in the region
    /// - Use optimizations to prune the search space early
    ///
    /// **Optimizations**:
    /// 1. Early rejection: If total present area > region area, impossible
    /// 2. Lexicographic ordering: When placing multiple identical shapes, enforce
    ///    placement order to avoid exploring symmetric duplicate solutions
    /// 3. Flat array grid: Use 1D boolean array instead of 2D for cache efficiency
    ///
    /// Time Complexity: O(R × P! × V × W × H) worst case, heavily pruned in practice
    ///   where R = regions, P = presents per region, V = variants (≤8), W/H = dimensions
    /// Space Complexity: O(W × H) for grid state
    func part1() -> Int {
        let (shapes, regions) = parse()

        // Precompute all rotation/flip variants for each shape
        let allShapeVariants = shapes.map { $0.allVariants() }

        var regionsWithSolution = 0
        for region in regions {
            if canFitAllPresents(in: region, shapeVariants: allShapeVariants) {
                regionsWithSolution += 1
            }
        }

        return regionsWithSolution
    }

    /// Determine if all required presents can fit in the given region
    private func canFitAllPresents(in region: Region, shapeVariants: [[Shape]]) -> Bool {
        // Expand present counts into individual presents to place
        // Each entry stores (shapeIndex, cellCount) for that present
        var presentsToPlace: [(shapeIndex: Int, cellCount: Int)] = []
        var totalCellsNeeded = 0

        for (shapeIndex, count) in region.presentCounts.enumerated() {
            if shapeIndex < shapeVariants.count {
                let cellCount = shapeVariants[shapeIndex][0].cellCount
                for _ in 0..<count {
                    presentsToPlace.append((shapeIndex, cellCount))
                    totalCellsNeeded += cellCount
                }
            }
        }

        // Early termination: impossible if presents need more space than available
        let availableArea = region.width * region.height
        if totalCellsNeeded > availableArea {
            return false
        }

        // Empty region is always valid
        if presentsToPlace.isEmpty {
            return true
        }

        // Sort presents by shape index to group identical shapes together
        // This enables lexicographic ordering optimization in backtracking
        presentsToPlace.sort { $0.shapeIndex < $1.shapeIndex }

        // Use flat 1D boolean array as grid (better cache locality than 2D)
        var grid = [Bool](repeating: false, count: region.width * region.height)

        return tryPlacingPresents(
            grid: &grid,
            width: region.width,
            height: region.height,
            presentsToPlace: presentsToPlace,
            currentPresentIndex: 0,
            shapeVariants: shapeVariants,
            remainingCells: totalCellsNeeded,
            minPlacementX: 0,
            minPlacementY: 0
        )
    }

    /// Recursive backtracking to place presents one at a time
    ///
    /// **Key Optimization - Lexicographic Ordering**:
    /// When placing multiple identical shapes, we enforce that each subsequent
    /// identical shape must be placed at a position >= the previous one (in
    /// row-major order). This prevents exploring symmetric duplicate solutions.
    ///
    /// Example: If placing two identical L-shapes, we don't try:
    ///   - Solution A: L1 at (0,0), L2 at (2,0)
    ///   - Solution B: L1 at (2,0), L2 at (0,0)  <- Skip this (same as A)
    ///
    /// For different shapes, we reset and can place anywhere from (0,0).
    private func tryPlacingPresents(
        grid: inout [Bool],
        width: Int,
        height: Int,
        presentsToPlace: [(shapeIndex: Int, cellCount: Int)],
        currentPresentIndex: Int,
        shapeVariants: [[Shape]],
        remainingCells: Int,
        minPlacementX: Int,
        minPlacementY: Int
    ) -> Bool {
        // Base case: all presents successfully placed
        if currentPresentIndex == presentsToPlace.count {
            return true
        }

        let currentShapeIndex = presentsToPlace[currentPresentIndex].shapeIndex
        let variants = shapeVariants[currentShapeIndex]

        // Apply lexicographic ordering for identical shapes
        // Start searching from the minimum allowed position
        let startY = minPlacementY
        let startX = minPlacementX

        // Try each orientation of the current shape
        for variant in variants {
            // Try placing at each valid position in row-major order
            for y in startY..<height {
                let xStart = (y == startY) ? startX : 0

                for x in xStart..<width {
                    if canPlaceShape(variant, atX: x, atY: y, in: grid, width: width, height: height) {
                        // Place the shape on the grid
                        placeShape(variant, atX: x, atY: y, in: &grid, width: width, occupied: true)

                        // Determine minimum position for next present
                        let nextMinX: Int
                        let nextMinY: Int

                        if currentPresentIndex + 1 < presentsToPlace.count &&
                           presentsToPlace[currentPresentIndex + 1].shapeIndex == currentShapeIndex {
                            // Next present is same shape - enforce lexicographic ordering
                            nextMinX = x
                            nextMinY = y
                        } else {
                            // Next present is different shape - can place anywhere
                            nextMinX = 0
                            nextMinY = 0
                        }

                        // Recursively try to place remaining presents
                        if tryPlacingPresents(
                            grid: &grid,
                            width: width,
                            height: height,
                            presentsToPlace: presentsToPlace,
                            currentPresentIndex: currentPresentIndex + 1,
                            shapeVariants: shapeVariants,
                            remainingCells: remainingCells - variant.cellCount,
                            minPlacementX: nextMinX,
                            minPlacementY: nextMinY
                        ) {
                            return true // Found a valid solution
                        }

                        // Backtrack: remove the shape and try next position
                        placeShape(variant, atX: x, atY: y, in: &grid, width: width, occupied: false)
                    }
                }
            }
        }

        return false // No valid placement found for this present
    }

    /// Check if a shape can be placed at position (placementX, placementY)
    /// Returns false if any cell would be out of bounds or overlap existing shapes
    @inline(__always)
    private func canPlaceShape(
        _ shape: Shape,
        atX placementX: Int,
        atY placementY: Int,
        in grid: [Bool],
        width: Int,
        height: Int
    ) -> Bool {
        for cell in shape.cells {
            let x = placementX + cell.x
            let y = placementY + cell.y

            // Check bounds and collision
            if x >= width || y >= height || grid[y * width + x] {
                return false
            }
        }
        return true
    }

    /// Place or remove a shape on the grid
    /// - occupied: true to mark cells as occupied, false to clear them (backtracking)
    @inline(__always)
    private func placeShape(
        _ shape: Shape,
        atX placementX: Int,
        atY placementY: Int,
        in grid: inout [Bool],
        width: Int,
        occupied: Bool
    ) {
        for cell in shape.cells {
            let flatIndex = (placementY + cell.y) * width + (placementX + cell.x)
            grid[flatIndex] = occupied
        }
    }

    /// Part 2: Narrative conclusion - no additional computation required
    ///
    /// After solving Part 1, the Elves successfully arrange the presents and
    /// the story concludes with a magical star appearing. Both stars are awarded
    /// automatically upon completing Part 1.
    func part2() -> Int {
        // Part 2 was a narrative conclusion with no computational component
        0
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

        let day = Day12(input: input)

        print("Day 12 - Christmas Tree Farm")
        print("============================")
        print("Part 1: \(day.part1())")
        print("Part 2: ⭐ (Narrative conclusion - both stars earned!)")
    }
}
