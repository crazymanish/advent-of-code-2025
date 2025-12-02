import Foundation

struct Day02 {
    let input: String

    /// Checks if a number is "invalid" - made of some sequence of digits repeated twice.
    /// Examples: 55 (5+5), 6464 (64+64), 123123 (123+123)
    /// - Parameter n: The number to check
    /// - Returns: true if the number is made of a repeated digit sequence
    private func isInvalidID(_ n: Int) -> Bool {
        let str = String(n)
        let length = str.count

        // Must have even number of digits to be a repeated sequence
        if length % 2 != 0 {
            return false
        }

        let halfLength = length / 2
        let firstHalf = str.prefix(halfLength)
        let secondHalf = str.suffix(halfLength)

        return firstHalf == secondHalf
    }

    /// Parses a range string like "11-22" into (start, end) tuple
    /// - Parameter rangeStr: A string in format "start-end"
    /// - Returns: A tuple of (start, end) integers
    private func parseRange(_ rangeStr: String) -> (Int, Int) {
        let parts = rangeStr.split(separator: "-")
        return (Int(parts[0])!, Int(parts[1])!)
    }

    /// Generates all invalid IDs (repeated digit sequences) within a given range.
    /// Instead of checking every number in the range, we generate candidates
    /// by creating repeated sequences and checking if they fall within the range.
    /// - Parameters:
    ///   - start: Start of the range (inclusive)
    ///   - end: End of the range (inclusive)
    /// - Returns: Array of invalid IDs in the range
    private func findInvalidIDsInRange(start: Int, end: Int) -> [Int] {
        var invalidIDs: [Int] = []

        // Determine the digit lengths we need to check
        // A repeated sequence of length L produces a number with 2*L digits
        let minDigits = String(start).count
        let maxDigits = String(end).count

        // For each possible half-length (the sequence that gets repeated)
        for halfDigits in 1...((maxDigits + 1) / 2) {
            let minHalf = halfDigits == 1 ? 1 : Int(pow(10.0, Double(halfDigits - 1)))
            let maxHalf = Int(pow(10.0, Double(halfDigits))) - 1

            for half in minHalf...maxHalf {
                // Create the repeated number: e.g., 123 -> 123123
                let halfStr = String(half)
                let repeated = Int(halfStr + halfStr)!

                if repeated >= start && repeated <= end {
                    invalidIDs.append(repeated)
                }
            }
        }

        return invalidIDs
    }

    /// Checks if a number is "invalid" for Part 2 - made of some sequence of digits repeated at least twice.
    /// Examples: 55 (5×2), 111 (1×3), 6464 (64×2), 123123123 (123×3)
    /// - Parameter n: The number to check
    /// - Returns: true if the number is made of a repeated digit sequence (2+ times)
    private func isInvalidIDPart2(_ n: Int) -> Bool {
        let str = String(n)
        let length = str.count

        // Try all possible base sequence lengths (must divide total length, with quotient >= 2)
        for baseLength in 1...(length / 2) {
            if length % baseLength == 0 {
                let repetitions = length / baseLength
                if repetitions >= 2 {
                    let base = String(str.prefix(baseLength))
                    let repeated = String(repeating: base, count: repetitions)
                    if repeated == str {
                        return true
                    }
                }
            }
        }

        return false
    }

    /// Generates all invalid IDs (repeated digit sequences, at least 2 times) within a given range for Part 2.
    /// - Parameters:
    ///   - start: Start of the range (inclusive)
    ///   - end: End of the range (inclusive)
    /// - Returns: Set of invalid IDs in the range (using Set to avoid duplicates)
    private func findInvalidIDsInRangePart2(start: Int, end: Int) -> Set<Int> {
        var invalidIDs: Set<Int> = []

        let maxDigits = String(end).count

        // For each possible base length
        for baseLength in 1...(maxDigits / 2) {
            let minBase = baseLength == 1 ? 1 : Int(pow(10.0, Double(baseLength - 1)))
            let maxBase = Int(pow(10.0, Double(baseLength))) - 1

            // For each possible repetition count (at least 2)
            for repetitions in 2...(maxDigits / baseLength) {
                let resultDigits = baseLength * repetitions
                if resultDigits > maxDigits {
                    break
                }

                for base in minBase...maxBase {
                    let baseStr = String(base)
                    let repeated = Int(String(repeating: baseStr, count: repetitions))!

                    if repeated >= start && repeated <= end {
                        invalidIDs.insert(repeated)
                    }
                }
            }
        }

        return invalidIDs
    }

    /// Solves Part 1: Find all invalid IDs (numbers made of repeated digit sequences)
    /// in the given ranges and return their sum.
    ///
    /// Algorithm:
    /// 1. Parse each range from the input
    /// 2. For each range, generate all possible repeated-sequence numbers that fall within it
    /// 3. Sum all the invalid IDs found
    ///
    /// Time Complexity: O(R * 10^(D/2)) where R is number of ranges, D is max digits in range end
    ///   - For each range, we generate candidates based on half the max digit length
    ///   - Much more efficient than checking every number in the range
    /// Space Complexity: O(I) where I is the total number of invalid IDs found
    func part1() -> Int {
        let ranges = input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ",")
            .map { String($0) }

        var totalSum = 0

        for rangeStr in ranges {
            let (start, end) = parseRange(rangeStr)
            let invalidIDs = findInvalidIDsInRange(start: start, end: end)
            totalSum += invalidIDs.reduce(0, +)
        }

        return totalSum
    }

    /// Solves Part 2: Find all invalid IDs (numbers made of repeated digit sequences at least 2 times)
    /// in the given ranges and return their sum.
    ///
    /// Algorithm:
    /// 1. Parse each range from the input
    /// 2. For each range, generate all possible repeated-sequence numbers (2+ repetitions) that fall within it
    /// 3. Use a Set to avoid counting duplicates (e.g., 1111 = 1×4 = 11×2)
    /// 4. Sum all the invalid IDs found
    ///
    /// Time Complexity: O(R * D * 10^(D/2)) where R is number of ranges, D is max digits in range end
    /// Space Complexity: O(I) where I is the total number of invalid IDs found
    func part2() -> Int {
        let ranges = input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ",")
            .map { String($0) }

        var totalSum = 0

        for rangeStr in ranges {
            let (start, end) = parseRange(rangeStr)
            let invalidIDs = findInvalidIDsInRangePart2(start: start, end: end)
            totalSum += invalidIDs.reduce(0, +)
        }

        return totalSum
    }
}

// Main entry point
@main
struct Day02Main {
    static func main() {
        let inputPath = Bundle.module.path(forResource: "input", ofType: "txt")!
        let input = try! String(contentsOfFile: inputPath, encoding: .utf8)

        let solver = Day02(input: input)

        print("Part 1: \(solver.part1())")
        print("Part 2: \(solver.part2())")
    }
}
