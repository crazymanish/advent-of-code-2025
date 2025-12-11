import Foundation

// MARK: - Day 11: Reactor
//
// Problem: We have a directed graph of devices where data flows from outputs.
// We need to count paths between specific nodes.
//
// Key Insight: The device graph forms a DAG (Directed Acyclic Graph) for valid paths,
// which allows us to use memoization to count paths efficiently in O(V+E) time
// instead of enumerating all paths (which could be exponential).

struct Day11 {
    let input: String

    /// Adjacency list representation of the device graph
    /// Key: device name, Value: list of devices it outputs to
    let deviceGraph: [String: [String]]

    init(input: String) {
        self.input = input
        self.deviceGraph = Self.parseInput(input)
    }

    // MARK: - Input Parsing

    /// Parses the puzzle input into a directed graph (adjacency list)
    ///
    /// Input format: "device: output1 output2 output3"
    /// Example: "bbb: ddd eee" means device "bbb" has outputs to "ddd" and "eee"
    private static func parseInput(_ input: String) -> [String: [String]] {
        var graph: [String: [String]] = [:]

        for line in input.components(separatedBy: "\n") where !line.isEmpty {
            let parts = line.components(separatedBy: ": ")
            guard parts.count == 2 else { continue }

            let deviceName = parts[0]
            let outputDevices = parts[1].components(separatedBy: " ")
            graph[deviceName] = outputDevices
        }

        return graph
    }

    // MARK: - Path Counting Algorithm

    /// Counts all paths from `sourceDevice` to `destinationDevice` using memoized DFS.
    ///
    /// Algorithm:
    /// - Use depth-first search starting from source
    /// - At each node, recursively count paths from all its outputs to destination
    /// - Sum up all paths and cache the result to avoid recomputation
    /// - Handle cycles by tracking nodes currently being computed (on the recursion stack)
    ///
    /// Why memoization works:
    /// - The number of paths from node X to destination is always the same,
    ///   regardless of how we reached node X
    /// - This transforms O(2^n) path enumeration into O(V+E) graph traversal
    ///
    /// - Parameters:
    ///   - sourceDevice: Starting device for path counting
    ///   - destinationDevice: Target device where paths should end
    /// - Returns: Total number of distinct paths from source to destination
    private func countPaths(from sourceDevice: String, to destinationDevice: String) -> Int {
        // Cache: device -> number of paths from that device to destination
        var pathCountCache: [String: Int] = [:]

        // Track devices currently on the recursion stack to detect cycles
        // If we encounter a device already being computed, we've found a cycle
        var devicesOnStack = Set<String>()

        func countPathsFromDevice(_ currentDevice: String) -> Int {
            // Base case: reached the destination - this is one valid path
            if currentDevice == destinationDevice {
                return 1
            }

            // Return cached result if we've already computed paths from this device
            if let cachedPathCount = pathCountCache[currentDevice] {
                return cachedPathCount
            }

            // Cycle detection: if this device is already on the stack,
            // we're in a cycle - return 0 to avoid infinite recursion
            if devicesOnStack.contains(currentDevice) {
                return 0
            }

            // No outputs from this device means no paths to destination
            guard let outputDevices = deviceGraph[currentDevice] else {
                pathCountCache[currentDevice] = 0
                return 0
            }

            // Mark device as being computed (on recursion stack)
            devicesOnStack.insert(currentDevice)

            // Sum paths through all output devices
            // paths(current->dest) = Σ paths(output->dest) for all outputs
            var totalPaths = 0
            for outputDevice in outputDevices {
                totalPaths += countPathsFromDevice(outputDevice)
            }

            // Remove from stack as we're done computing this device
            devicesOnStack.remove(currentDevice)

            // Cache and return the result
            pathCountCache[currentDevice] = totalPaths
            return totalPaths
        }

        return countPathsFromDevice(sourceDevice)
    }

    // MARK: - Part 1

    /// Part 1: Count all paths from "you" to "out"
    ///
    /// Algorithm: Simple path counting using memoized DFS
    /// - Start from device "you" (where we're standing)
    /// - Count all paths that reach device "out" (reactor output)
    ///
    /// Time Complexity: O(V + E) where V = devices, E = connections
    /// Space Complexity: O(V) for memoization cache and recursion stack
    func part1() -> Int {
        return countPaths(from: "you", to: "out")
    }

    // MARK: - Part 2

    /// Part 2: Count paths from "svr" to "out" that visit BOTH "dac" AND "fft"
    ///
    /// Algorithm: Decompose the problem using path multiplication
    ///
    /// Key Insight: A path visiting both "dac" and "fft" must visit them in one of two orders:
    /// 1. Visit "dac" first, then "fft": svr → ... → dac → ... → fft → ... → out
    /// 2. Visit "fft" first, then "dac": svr → ... → fft → ... → dac → ... → out
    ///
    /// For case 1 (dac before fft):
    ///   Total paths = paths(svr→dac) × paths(dac→fft) × paths(fft→out)
    ///
    /// For case 2 (fft before dac):
    ///   Total paths = paths(svr→fft) × paths(fft→dac) × paths(dac→out)
    ///
    /// Why multiplication works:
    /// - Each path from svr to dac can be combined with any path from dac to fft
    /// - And each of those can be combined with any path from fft to out
    /// - This is the multiplication principle of counting
    ///
    /// Why no double-counting:
    /// - A path cannot visit dac→fft→dac (would require revisiting dac)
    /// - In a DAG with cycle prevention, each node is visited at most once per path
    /// - So the two cases (dac-first vs fft-first) are mutually exclusive
    ///
    /// Time Complexity: O(V + E) - each path count is memoized
    /// Space Complexity: O(V) for memoization cache
    func part2() -> Int {
        // Case 1: Paths where we visit DAC before FFT
        // svr → ... → dac → ... → fft → ... → out
        let pathsFromSvrToDac = countPaths(from: "svr", to: "dac")
        let pathsFromDacToFft = countPaths(from: "dac", to: "fft")
        let pathsFromFftToOut = countPaths(from: "fft", to: "out")
        let pathsWithDacBeforeFft = pathsFromSvrToDac * pathsFromDacToFft * pathsFromFftToOut

        // Case 2: Paths where we visit FFT before DAC
        // svr → ... → fft → ... → dac → ... → out
        let pathsFromSvrToFft = countPaths(from: "svr", to: "fft")
        let pathsFromFftToDac = countPaths(from: "fft", to: "dac")
        let pathsFromDacToOut = countPaths(from: "dac", to: "out")
        let pathsWithFftBeforeDac = pathsFromSvrToFft * pathsFromFftToDac * pathsFromDacToOut

        // Total = paths with dac first + paths with fft first (mutually exclusive)
        return pathsWithDacBeforeFft + pathsWithFftBeforeDac
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

        let day = Day11(input: input)

        print("Day 11 - Reactor")
        print("========================")
        print("Part 1: \(day.part1())")
        print("Part 2: \(day.part2())")
    }
}
