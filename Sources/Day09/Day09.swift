import Foundation

struct Point: Hashable {
    let x: Int
    let y: Int
}

struct Day09 {
    let input: String

    init(input: String) {
        self.input = input
    }

    /// Parse input to get list of red tile coordinates
    private func parseInput() -> [Point] {
        input.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
            .compactMap { line -> Point? in
                let parts = line.components(separatedBy: ",")
                guard parts.count == 2,
                      let x = Int(parts[0]),
                      let y = Int(parts[1]) else {
                    return nil
                }
                return Point(x: x, y: y)
            }
    }

    /// Calculate rectangle area given two opposite corners (inclusive)
    private func rectangleArea(_ p1: Point, _ p2: Point) -> Int {
        (abs(p2.x - p1.x) + 1) * (abs(p2.y - p1.y) + 1)
    }

    /// Find the largest rectangle with red tiles at opposite corners
    /// - Parameter validateInsidePolygon: If true, rectangle must contain only red/green tiles
    ///
    /// ALGORITHM:
    /// Part 1: Simple brute force - try all pairs of red tiles as opposite corners
    ///   - For each pair (i, j) of red tiles, calculate rectangle area
    ///   - Track maximum area found
    ///   - No constraints on interior tiles
    ///
    /// Part 2: Same pairing, but with polygon validation
    ///   - Red tiles form a rectilinear polygon boundary
    ///   - Rectangle interior must contain ONLY red/green tiles (inside polygon)
    ///   - Use ray casting to test if cells/edges are inside polygon
    ///   - Optimize with coordinate compression + 2D prefix sums for O(1) validation
    ///
    /// Time Complexity: O(n²) for part1, O(n² + k²) for part2 where k = unique coordinates
    /// Space Complexity: O(n) for part1, O(k²) for part2 (prefix sum grids)
    private func findMaxRectangle(validateInsidePolygon: Bool) -> Int {
        let redPoints = parseInput()
        guard redPoints.count >= 2 else { return 0 }

        // Build polygon validation only if needed for Part 2
        let validator: ((Point, Point) -> Bool)? = validateInsidePolygon
            ? buildPolygonValidator(redPoints: redPoints)
            : nil

        var maxArea = 0
        for i in 0..<redPoints.count {
            for j in (i + 1)..<redPoints.count {
                let p1 = redPoints[i], p2 = redPoints[j]

                // Part 1: always valid. Part 2: check if inside polygon
                let isValid = validator?(p1, p2) ?? true

                if isValid {
                    maxArea = max(maxArea, rectangleArea(p1, p2))
                }
            }
        }
        return maxArea
    }

    /// Build a validator function that checks if a rectangle is fully inside the polygon
    ///
    /// PART 2 OPTIMIZATION STRATEGY:
    /// 1. Build polygon edges from red tiles (rectilinear polygon)
    /// 2. Use coordinate compression to reduce grid size (only unique x,y coordinates)
    /// 3. Precompute 4 grids using ray casting:
    ///    - cellGrid: interior of cells between coordinates
    ///    - rightEdgeGrid: right edge of rectangle
    ///    - topEdgeGrid: top edge of rectangle
    ///    - cornerGrid: corner points
    /// 4. Build 2D prefix sums on first 3 grids for O(1) range sum queries
    /// 5. Return validator closure that checks rectangle in O(1) time
    private func buildPolygonValidator(redPoints: [Point]) -> (Point, Point) -> Bool {
        // STEP 1: Build polygon edges from connected red tiles
        // Red tiles form a rectilinear polygon (only horizontal/vertical edges)
        var horizontalEdges: [(y: Int, xMin: Int, xMax: Int)] = []
        var verticalEdges: [(x: Int, yMin: Int, yMax: Int)] = []

        for i in 0..<redPoints.count {
            let p1 = redPoints[i]
            let p2 = redPoints[(i + 1) % redPoints.count]
            if p1.y == p2.y {
                horizontalEdges.append((y: p1.y, xMin: min(p1.x, p2.x), xMax: max(p1.x, p2.x)))
            } else if p1.x == p2.x {
                verticalEdges.append((x: p1.x, yMin: min(p1.y, p2.y), yMax: max(p1.y, p2.y)))
            }
        }

        // STEP 2: Coordinate compression
        // Instead of a grid with ~90,000 coordinates, use only unique x,y values
        // Example: x coords [0, 100, 1000] -> indices [0, 1, 2] (size 3 instead of 1001)
        let sortedX = Set(redPoints.map { $0.x }).sorted()
        let sortedY = Set(redPoints.map { $0.y }).sorted()
        let xToIdx = Dictionary(uniqueKeysWithValues: sortedX.enumerated().map { ($1, $0) })
        let yToIdx = Dictionary(uniqueKeysWithValues: sortedY.enumerated().map { ($1, $0) })
        let numX = sortedX.count
        let numY = sortedY.count

        // STEP 3a: Point-in-polygon check using ray casting algorithm
        // Cast a ray from point to the right, count vertical edge crossings
        // Odd crossings = inside, even = outside
        func isInsidePolygon(_ x: Int, _ y: Int) -> Bool {
            // Points ON the polygon boundary are considered inside
            for edge in horizontalEdges {
                if y == edge.y && x >= edge.xMin && x <= edge.xMax { return true }
            }
            for edge in verticalEdges {
                if x == edge.x && y >= edge.yMin && y <= edge.yMax { return true }
            }
            // Ray casting: count vertical edges to the right of point
            var crossings = 0
            for edge in verticalEdges {
                if edge.x > x && y > edge.yMin && y < edge.yMax { crossings += 1 }
            }
            return crossings % 2 == 1
        }

        // STEP 3b: Precompute 4 grids for all possible rectangle components
        // These grids map compressed coordinates to whether that region is inside polygon
        // +1 padding for prefix sum indexing (1-indexed)
        var cellGrid = Array(repeating: Array(repeating: 0, count: numY + 1), count: numX + 1)
        var rightEdgeGrid = Array(repeating: Array(repeating: 0, count: numY + 1), count: numX + 1)
        var topEdgeGrid = Array(repeating: Array(repeating: 0, count: numY + 1), count: numX + 1)
        var cornerGrid = Array(repeating: Array(repeating: false, count: numY), count: numX)

        for i in 0..<numX {
            for j in 0..<numY {
                // Corner: exact coordinate point (e.g., top-right corner of rectangle)
                cornerGrid[i][j] = isInsidePolygon(sortedX[i], sortedY[j])

                // Cell interior: midpoint between consecutive coordinates
                // Represents the area between grid lines
                if i + 1 < numX && j + 1 < numY {
                    let midX = (sortedX[i] + sortedX[i + 1]) / 2
                    let midY = (sortedY[j] + sortedY[j + 1]) / 2
                    cellGrid[i + 1][j + 1] = isInsidePolygon(midX, midY) ? 1 : 0
                }

                // Right edge: vertical line at x=sortedX[i], between y coordinates
                if j + 1 < numY {
                    let midY = (sortedY[j] + sortedY[j + 1]) / 2
                    rightEdgeGrid[i + 1][j + 1] = isInsidePolygon(sortedX[i], midY) ? 1 : 0
                }

                // Top edge: horizontal line at y=sortedY[j], between x coordinates
                if i + 1 < numX {
                    let midX = (sortedX[i] + sortedX[i + 1]) / 2
                    topEdgeGrid[i + 1][j + 1] = isInsidePolygon(midX, sortedY[j]) ? 1 : 0
                }
            }
        }

        // STEP 4: Build 2D prefix sums for O(1) range queries
        // Prefix sum allows counting 1s in any rectangle in constant time
        // Formula: sum[i][j] = current + left + top - diagonal
        func buildPrefixSum(_ grid: inout [[Int]]) {
            for i in 1...numX {
                for j in 1...numY {
                    grid[i][j] += grid[i-1][j] + grid[i][j-1] - grid[i-1][j-1]
                }
            }
        }

        buildPrefixSum(&cellGrid)
        buildPrefixSum(&rightEdgeGrid)
        buildPrefixSum(&topEdgeGrid)

        // STEP 5: Range sum query in O(1) using inclusion-exclusion principle
        // Returns count of 1s in rectangle [x1,y1] to [x2,y2] (1-indexed, inclusive)
        func rangeSum(_ grid: [[Int]], _ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) -> Int {
            grid[x2][y2] - grid[x1-1][y2] - grid[x2][y1-1] + grid[x1-1][y1-1]
        }

        // STEP 6: Return validator closure - O(1) per rectangle check!
        // For rectangle from (minX, minY) to (maxX, maxY), verify ALL components are inside:
        // 1. All cell interiors (regions between coordinates)
        // 2. Right edge (vertical line at maxX)
        // 3. Top edge (horizontal line at maxY)
        // 4. Top-right corner (exact point maxX, maxY)
        return { p1, p2 in
            let minX = min(p1.x, p2.x), maxX = max(p1.x, p2.x)
            let minY = min(p1.y, p2.y), maxY = max(p1.y, p2.y)

            // Map real coordinates to compressed indices
            guard let minXIdx = xToIdx[minX], let maxXIdx = xToIdx[maxX],
                  let minYIdx = yToIdx[minY], let maxYIdx = yToIdx[maxY] else { return false }

            // Verify all cell interiors are inside polygon using prefix sum
            // Expected: all cells should be inside (count should equal sum)
            let cellCount = (maxXIdx - minXIdx) * (maxYIdx - minYIdx)
            if cellCount > 0 {
                let cellSum = rangeSum(cellGrid, minXIdx + 1, minYIdx + 1, maxXIdx, maxYIdx)
                if cellSum != cellCount { return false }
            }

            // Verify right edge is fully inside polygon
            let rightEdgeCount = maxYIdx - minYIdx
            if rightEdgeCount > 0 {
                let rightSum = rangeSum(rightEdgeGrid, maxXIdx + 1, minYIdx + 1, maxXIdx + 1, maxYIdx)
                if rightSum != rightEdgeCount { return false }
            }

            // Verify top edge is fully inside polygon
            let topEdgeCount = maxXIdx - minXIdx
            if topEdgeCount > 0 {
                let topSum = rangeSum(topEdgeGrid, minXIdx + 1, maxYIdx + 1, maxXIdx, maxYIdx + 1)
                if topSum != topEdgeCount { return false }
            }

            // Verify top-right corner is inside polygon
            return cornerGrid[maxXIdx][maxYIdx]
        }
    }

    /// Part 1: Largest rectangle with red corners (no constraints on interior)
    ///
    /// ALGORITHM: Brute force all O(n²) pairs of red tiles
    /// - Try each pair as opposite corners of a rectangle
    /// - Calculate area: (|x2-x1|+1) × (|y2-y1|+1)
    /// - Return maximum area found
    ///
    /// Time: O(n²), Space: O(n)
    func part1() -> Int {
        findMaxRectangle(validateInsidePolygon: false)
    }

    /// Part 2: Largest rectangle with red corners containing only red/green tiles
    ///
    /// ALGORITHM: Same O(n²) pairing, but with polygon validation
    /// - Red tiles form a rectilinear polygon boundary
    /// - Rectangle must be entirely inside this polygon
    /// - Use coordinate compression + 2D prefix sums for fast validation
    /// - Each validation is O(1) after O(k²) preprocessing
    ///
    /// Time: O(n² + k²), Space: O(k²) where k = unique coordinates (~100-200)
    func part2() -> Int {
        findMaxRectangle(validateInsidePolygon: true)
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

        let day = Day09(input: input)

        print("Day 09 - Movie Theater")
        print("========================")
        print("Part 1: \(day.part1())")
        print("Part 2: \(day.part2())")
    }
}
