import Foundation

struct Day05 {
    let input: String

    init(input: String) {
        self.input = input
    }

    /// Part 1: Count how many available ingredient IDs fall inside any fresh range.
    ///
    /// Algorithm:
    /// 1. Normalize the input and split it into the range block and the ID block.
    /// 2. Parse all inclusive ranges and merge overlaps (and adjacent edges) to minimize membership checks.
    /// 3. Parse all available IDs and, for each, binary-search the merged ranges to determine freshness.
    ///
    /// Time Complexity: O(r log r + a log r) where r is number of ranges and a the number of available IDs
    /// Space Complexity: O(r) to store the merged ranges; IDs are processed from their list
    func part1() -> Int {
        let (ranges, ids) = parseDatabase()
        guard !ranges.isEmpty else { return 0 }

        let mergedRanges = mergeRanges(ranges)
        var freshCount = 0

        for id in ids {
            if isFresh(id, in: mergedRanges) {
                freshCount += 1
            }
        }

        return freshCount
    }

    /// Part 2: Count the total number of unique IDs covered by at least one fresh range.
    ///
    /// Algorithm:
    /// 1. Parse and merge all ranges (same as Part 1).
    /// 2. Sum the length of each merged interval (inclusive) to obtain the total count.
    ///
    /// Time Complexity: O(r log r) to sort/merge r ranges
    /// Space Complexity: O(r) for the merged ranges
    func part2() -> Int {
        let (ranges, _) = parseDatabase()
        guard !ranges.isEmpty else { return 0 }

        let mergedRanges = mergeRanges(ranges)
        return mergedRanges.reduce(0) { partial, range in
            partial + (range.1 - range.0 + 1)
        }
    }

    private func parseDatabase() -> ([(Int, Int)], [Int]) {
        let normalized = input
            .replacingOccurrences(of: "\r\n", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let separatorRange = normalized.range(of: "\n\n")
        let rangeSection: String
        let idSection: String

        if let separatorRange = separatorRange {
            rangeSection = String(normalized[..<separatorRange.lowerBound])
            idSection = String(normalized[separatorRange.upperBound...])
        } else {
            rangeSection = normalized
            idSection = ""
        }

        let rangeLines = rangeSection
            .split(whereSeparator: \.isNewline)
            .map { String($0) }

        let ranges: [(Int, Int)] = rangeLines.compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { return nil }
            let parts = trimmed.split(separator: "-", maxSplits: 1)
            guard parts.count == 2,
                  let start = Int(parts[0]),
                  let end = Int(parts[1]) else {
                return nil
            }
            if start <= end {
                return (start, end)
            } else {
                return (end, start)
            }
        }

        let idLines = idSection
            .split(whereSeparator: \.isNewline)
            .map { String($0) }

        let ids: [Int] = idLines.compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return Int(trimmed)
        }

        return (ranges, ids)
    }

    private func mergeRanges(_ ranges: [(Int, Int)]) -> [(Int, Int)] {
        guard !ranges.isEmpty else { return [] }

        let sorted = ranges.sorted { lhs, rhs in
            if lhs.0 == rhs.0 {
                return lhs.1 < rhs.1
            }
            return lhs.0 < rhs.0
        }

        var merged: [(Int, Int)] = []
        merged.reserveCapacity(sorted.count)
        merged.append(sorted[0])

        for index in 1..<sorted.count {
            let current = sorted[index]
            var last = merged.removeLast()

            if current.0 <= last.1 + 1 {
                last.1 = max(last.1, current.1)
                merged.append(last)
            } else {
                merged.append(last)
                merged.append(current)
            }
        }

        return merged
    }

    private func isFresh(_ id: Int, in mergedRanges: [(Int, Int)]) -> Bool {
        guard !mergedRanges.isEmpty else { return false }

        var low = 0
        var high = mergedRanges.count - 1

        while low <= high {
            let mid = (low + high) / 2
            let range = mergedRanges[mid]

            if id < range.0 {
                high = mid - 1
            } else if id > range.1 {
                low = mid + 1
            } else {
                return true
            }
        }

        return false
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

        let day = Day05(input: input)

        print("Day 05 - Cafeteria")
        print("===================")
        print("Part 1: \(day.part1())")
        print("Part 2: \(day.part2())")
    }
}
