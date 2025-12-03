import Foundation

struct Day03 {
    let input: String

    init(input: String) {
        self.input = input
    }

    /// Finds the maximum joltage by selecting exactly `selectCount` digits from a bank
    /// while maintaining their relative order.
    ///
    /// Greedy Algorithm:
    /// - For each position in the result (left to right), pick the largest available digit
    /// - Constraint: must leave enough digits to fill remaining positions
    /// - If we need k more digits and have n digits left, pick from first (n - k + 1) positions
    ///
    /// Time Complexity: O(n * k) where n is bank length, k is selectCount
    /// Space Complexity: O(n) for storing digits array
    func maxJoltageFromBank(_ bank: String, selectCount: Int) -> Int {
        let digits = Array(bank).compactMap { $0.wholeNumberValue }
        guard digits.count >= selectCount else { return 0 }

        var result: [Int] = []
        var startIndex = 0

        for i in 0..<selectCount {
            let remainingToSelect = selectCount - i
            let lastValidIndex = digits.count - remainingToSelect

            // Find the maximum digit in the valid range [startIndex, lastValidIndex]
            var maxDigit = -1
            var maxIndex = startIndex

            for j in startIndex...lastValidIndex {
                if digits[j] > maxDigit {
                    maxDigit = digits[j]
                    maxIndex = j
                    // Early exit if we found a 9 (can't do better)
                    if maxDigit == 9 { break }
                }
            }

            result.append(maxDigit)
            startIndex = maxIndex + 1
        }

        // Convert digits array to number
        return result.reduce(0) { $0 * 10 + $1 }
    }

    /// Part 1: Find the total output joltage (sum of maximum joltage from each bank)
    /// Selects exactly 2 batteries per bank.
    ///
    /// Time Complexity: O(m * n) where m is number of lines and n is average line length
    /// Space Complexity: O(n) for the suffix max array per line
    func part1() -> Int {
        let banks = input.components(separatedBy: .newlines).filter { !$0.isEmpty }
        return banks.reduce(0) { $0 + maxJoltageFromBank($1, selectCount: 2) }
    }

    /// Part 2: Find the total output joltage selecting exactly 12 batteries per bank.
    ///
    /// Time Complexity: O(m * n * k) where m is lines, n is line length, k is 12
    /// Space Complexity: O(n) for digits array per line
    func part2() -> Int {
        let banks = input.components(separatedBy: .newlines).filter { !$0.isEmpty }
        return banks.reduce(0) { $0 + maxJoltageFromBank($1, selectCount: 12) }
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

        let day = Day03(input: input)

        print("Day 03 - Lobby")
        print("========================")
        print("Part 1: \(day.part1())")
        print("Part 2: \(day.part2())")
    }
}
