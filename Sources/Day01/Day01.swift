import Foundation

struct Day01 {
    let input: String

    /// Parses a rotation instruction (e.g., "L68" or "R26") and returns the direction and distance.
    /// - Parameter instruction: A string like "L68" or "R26"
    /// - Returns: A tuple of (isLeft: Bool, distance: Int)
    private func parseRotation(_ instruction: String) -> (isLeft: Bool, distance: Int) {
        let direction = instruction.first!
        let distance = Int(instruction.dropFirst())!
        return (direction == "L", distance)
    }

    /// Solves Part 1: Count how many times the dial points at 0 after any rotation.
    ///
    /// Algorithm:
    /// 1. Start at position 50
    /// 2. For each rotation, update position (wrapping around 0-99)
    /// 3. Count times we land on 0
    ///
    /// Time Complexity: O(n) where n is the number of rotations
    /// Space Complexity: O(n) for storing the input lines (could be O(1) with streaming)
    func part1() -> Int {
        let rotations = input
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }

        var position = 50
        var zeroCount = 0

        for rotation in rotations {
            let (isLeft, distance) = parseRotation(rotation)

            if isLeft {
                position = (position - distance) % 100
                // Handle negative modulo (Swift's % can return negative)
                if position < 0 {
                    position += 100
                }
            } else {
                position = (position + distance) % 100
            }

            if position == 0 {
                zeroCount += 1
            }
        }

        return zeroCount
    }

    /// Counts how many times the dial passes through 0 during a rotation.
    /// - Parameters:
    ///   - position: Current dial position (0-99)
    ///   - isLeft: True if rotating left (toward lower numbers)
    ///   - distance: Number of clicks to rotate
    /// - Returns: Number of times the dial points at 0 during this rotation
    private func countZeroCrossings(position: Int, isLeft: Bool, distance: Int) -> Int {
        if isLeft {
            // LEFT rotation: dial decreases, wraps from 0 to 99
            // We hit 0 after exactly `position` clicks, then every 100 clicks after
            // Clicks where we hit 0: position, position+100, position+200, ...
            if position == 0 {
                // Special case: at 0, first zero after 100 clicks (full rotation)
                return distance / 100
            }
            if position > distance {
                return 0
            }
            return 1 + (distance - position) / 100
        } else {
            // RIGHT rotation: dial increases, wraps from 99 to 0
            // We hit 0 after (100 - position) clicks, then every 100 clicks after
            // Clicks where we hit 0: (100-position), (200-position), (300-position), ...
            let firstZeroAt = (position == 0) ? 100 : (100 - position)
            if firstZeroAt > distance {
                return 0
            }
            return 1 + (distance - firstZeroAt) / 100
        }
    }

    /// Solves Part 2: Count total times dial points at 0 during ANY click (not just at end).
    ///
    /// Algorithm:
    /// 1. Start at position 50
    /// 2. For each rotation, count how many times dial passes through 0
    /// 3. Sum all crossings
    ///
    /// Time Complexity: O(n) where n is the number of rotations
    /// Space Complexity: O(n) for storing the input lines
    func part2() -> Int {
        let rotations = input
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }

        var position = 50
        var zeroCount = 0

        for rotation in rotations {
            let (isLeft, distance) = parseRotation(rotation)

            // Count zero crossings during this rotation
            zeroCount += countZeroCrossings(position: position, isLeft: isLeft, distance: distance)

            // Update position
            if isLeft {
                position = (position - distance) % 100
                if position < 0 {
                    position += 100
                }
            } else {
                position = (position + distance) % 100
            }
        }

        return zeroCount
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

        let day = Day01(input: input)

        print("Day 01 - Secret Entrance")
        print("========================")
        print("Part 1: \(day.part1())")
        print("Part 2: \(day.part2())")
    }
}
