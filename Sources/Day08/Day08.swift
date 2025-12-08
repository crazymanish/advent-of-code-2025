import Foundation

// MARK: - Day 08: Playground
//
// Problem: Junction boxes in 3D space need to be connected with string lights.
// We connect pairs of junction boxes starting with the closest pairs first.
// When two boxes are connected, they form a "circuit" - electricity can flow between them.
//
// Key Data Structure: Union-Find (Disjoint Set Union)
// - Efficiently tracks which junction boxes belong to the same circuit
// - Supports near O(1) operations for finding and merging circuits
//
// Algorithm Overview:
// 1. Parse all junction box 3D coordinates
// 2. Compute distances between ALL pairs of junction boxes
// 3. Sort pairs by distance (closest first)
// 4. Process pairs in order, connecting them using Union-Find

struct Day08 {
    let input: String

    init(input: String) {
        self.input = input
    }

    /// Represents a 3D point (junction box position)
    struct Point3D {
        let x: Int
        let y: Int
        let z: Int
    }

    // MARK: - Union-Find (Disjoint Set Union) Data Structure
    //
    // This data structure efficiently manages disjoint sets (circuits).
    // Each junction box starts in its own set. When we connect two boxes,
    // we merge their sets into one.
    //
    // Two optimizations make operations nearly O(1):
    // 1. Path Compression: When finding a root, make all nodes point directly to root
    // 2. Union by Rank: Always attach smaller tree under larger tree's root

    class UnionFind {
        var parent: [Int]   // parent[i] = parent of node i (or itself if root)
        var rank: [Int]     // rank[i] = approximate depth of tree rooted at i
        var size: [Int]     // size[i] = number of nodes in tree rooted at i

        init(_ n: Int) {
            // Initially, each node is its own parent (each in its own set)
            parent = Array(0..<n)
            rank = Array(repeating: 0, count: n)
            size = Array(repeating: 1, count: n)
        }

        /// Find the root of the set containing x
        /// Uses path compression: makes every node on path point directly to root
        func find(_ x: Int) -> Int {
            if parent[x] != x {
                parent[x] = find(parent[x]) // Path compression
            }
            return parent[x]
        }

        /// Merge the sets containing x and y
        /// Uses union by rank: attach smaller tree under larger tree's root
        func union(_ x: Int, _ y: Int) {
            let rootX = find(x)
            let rootY = find(y)

            if rootX == rootY { return } // Already in same circuit

            // Union by rank: attach smaller tree under larger tree
            if rank[rootX] < rank[rootY] {
                parent[rootX] = rootY
                size[rootY] += size[rootX]
            } else if rank[rootX] > rank[rootY] {
                parent[rootY] = rootX
                size[rootX] += size[rootY]
            } else {
                parent[rootY] = rootX
                size[rootX] += size[rootY]
                rank[rootX] += 1
            }
        }

        /// Get sizes of all circuits, sorted in descending order
        func getCircuitSizes() -> [Int] {
            var sizes: [Int] = []
            for i in 0..<parent.count {
                if parent[i] == i { // This is a root (represents a circuit)
                    sizes.append(size[i])
                }
            }
            return sizes.sorted(by: >)
        }
    }

    /// Parse input into array of 3D points
    /// Input format: "X,Y,Z" per line
    func parseInput() -> [Point3D] {
        input.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
            .compactMap { line -> Point3D? in
                let parts = line.components(separatedBy: ",")
                guard parts.count == 3,
                      let x = Int(parts[0]),
                      let y = Int(parts[1]),
                      let z = Int(parts[2]) else { return nil }
                return Point3D(x: x, y: y, z: z)
            }
    }

    /// Calculate squared Euclidean distance between two 3D points
    /// We use squared distance (no sqrt) because we only need to compare distances,
    /// and sqrt is monotonic - if a² < b², then a < b
    func squaredDistance(_ a: Point3D, _ b: Point3D) -> Int {
        let dx = a.x - b.x
        let dy = a.y - b.y
        let dz = a.z - b.z
        return dx * dx + dy * dy + dz * dz
    }

    // MARK: - Part 1 Algorithm
    //
    // Goal: Connect the 1000 closest pairs of junction boxes, then find the
    //       product of the sizes of the three largest circuits.
    //
    // Steps:
    // 1. Parse all junction box coordinates
    // 2. Generate ALL pairs (i, j) with their distances - O(n²) pairs
    // 3. Sort pairs by distance (ascending) - closest pairs first
    // 4. Connect exactly 1000 pairs using Union-Find
    //    - Note: Some connections may be redundant (already in same circuit)
    //    - The puzzle says to make 1000 connections regardless
    // 5. Find all circuit sizes, take top 3, multiply them
    //
    /// Part 1: Connect 1000 closest pairs and multiply sizes of 3 largest circuits
    ///
    /// Time Complexity: O(n² log n) where n is number of junction boxes
    ///   - O(n²) to compute all pairwise distances
    ///   - O(n² log n) to sort all pairs
    ///   - O(k * α(n)) for k union operations with inverse Ackermann α(n)
    /// Space Complexity: O(n²) to store all pairwise distances
    func part1() -> Int {
        let points = parseInput()
        let n = points.count

        // Step 1: Generate all pairs with their squared distances
        // For n points, there are n*(n-1)/2 unique pairs
        var pairs: [(dist: Int, i: Int, j: Int)] = []
        for i in 0..<n {
            for j in (i + 1)..<n {
                let dist = squaredDistance(points[i], points[j])
                pairs.append((dist, i, j))
            }
        }

        // Step 2: Sort by distance (ascending) - closest pairs come first
        pairs.sort { $0.dist < $1.dist }

        // Step 3: Connect the 1000 closest pairs using Union-Find
        // Each union operation merges two circuits into one (if not already connected)
        let uf = UnionFind(n)
        let connectionsToMake = min(1000, pairs.count)

        for k in 0..<connectionsToMake {
            let (_, i, j) = pairs[k]
            uf.union(i, j)  // Connect junction boxes i and j
        }

        // Step 4: Get the three largest circuit sizes and multiply them
        let sizes = uf.getCircuitSizes()
        let top3 = sizes.prefix(3)
        return top3.reduce(1, *)
    }

    // MARK: - Part 2 Algorithm (Kruskal's MST)
    //
    // Goal: Keep connecting junction boxes until ALL are in ONE circuit.
    //       Return the product of X coordinates of the LAST two boxes connected.
    //
    // This is essentially Kruskal's Minimum Spanning Tree algorithm!
    // - A spanning tree connects all n nodes with exactly n-1 edges
    // - Kruskal's algorithm: greedily add shortest edge that doesn't create a cycle
    //
    // Steps:
    // 1. Parse all junction box coordinates
    // 2. Generate ALL pairs with their distances
    // 3. Sort pairs by distance (ascending)
    // 4. Iterate through pairs:
    //    - Skip if both boxes are already in the same circuit (would create cycle)
    //    - Connect if they're in different circuits (reduces circuit count by 1)
    //    - Track the last connection made
    //    - Stop when circuit count = 1 (all connected)
    // 5. Return product of X coordinates of last connected pair
    //
    /// Part 2: Connect all junction boxes into one circuit, return product of X coordinates of last pair
    ///
    /// Time Complexity: O(n² log n) where n is number of junction boxes
    ///   - O(n²) to compute all pairwise distances
    ///   - O(n² log n) to sort all pairs
    ///   - O(n² * α(n)) worst case for union operations
    /// Space Complexity: O(n²) to store all pairwise distances
    func part2() -> Int {
        let points = parseInput()
        let n = points.count

        // Step 1: Generate all pairs with their squared distances
        var pairs: [(dist: Int, i: Int, j: Int)] = []
        for i in 0..<n {
            for j in (i + 1)..<n {
                let dist = squaredDistance(points[i], points[j])
                pairs.append((dist, i, j))
            }
        }

        // Step 2: Sort by distance (ascending)
        pairs.sort { $0.dist < $1.dist }

        // Step 3: Connect pairs until all junction boxes are in one circuit
        // This is Kruskal's algorithm - we only connect boxes in DIFFERENT circuits
        let uf = UnionFind(n)
        var circuitCount = n  // Initially each junction box is its own circuit
        var lastConnection: (i: Int, j: Int) = (0, 0)

        for (_, i, j) in pairs {
            // Key difference from Part 1: Only connect if in DIFFERENT circuits
            // This ensures we're building a spanning tree (no cycles)
            if uf.find(i) != uf.find(j) {
                uf.union(i, j)
                circuitCount -= 1  // Merging two circuits reduces count by 1
                lastConnection = (i, j)  // Remember this connection

                // Stop when we have exactly one circuit (all connected)
                // A spanning tree of n nodes has exactly n-1 edges
                if circuitCount == 1 {
                    break
                }
            }
        }

        // Step 4: Return product of X coordinates of the last two junction boxes connected
        // This is the longest edge in our minimum spanning tree
        return points[lastConnection.i].x * points[lastConnection.j].x
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

        let day = Day08(input: input)

        print("Day 08 - Playground")
        print("========================")
        print("Part 1: \(day.part1())")
        print("Part 2: \(day.part2())")
    }
}
