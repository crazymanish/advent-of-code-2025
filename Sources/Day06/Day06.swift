import Foundation

struct Day06 {
    let input: String

    init(input: String) {
        self.input = input
    }

    /// Part 1: Solve each vertical problem and sum all results.
    ///
    /// Parsing strategy:
    /// 1. Normalize newlines and right-pad every row so columns align.
    /// 2. Identify separator columns that are entirely spaces to find each problem slice.
    /// 3. For each slice, read numbers from every row except the last, and read the operator from the last row.
    /// 4. Evaluate the slice with either addition or multiplication and accumulate the total.
    ///
    /// Time Complexity: O(r * c) to scan r rows of width c, plus O(p * n) to evaluate p problems with up to n numbers each
    /// Space Complexity: O(r * c) for the padded grid representation and O(p * n) for parsed numbers (bounded by input size)
    func part1() -> Int {
        let problems = parseVerticalProblems()
        guard !problems.isEmpty else { return 0 }

        var total = 0

        for problem in problems {
            guard !problem.numbers.isEmpty else { continue }

            let value: Int
            switch problem.operation {
            case "+":
                value = problem.numbers.reduce(0, +)
            case "*":
                value = problem.numbers.reduce(1, *)
            default:
                continue
            }

            total += value
        }

        return total
    }

    /// Part 2: Solve each problem when numbers are read column-wise right-to-left, then sum results.
    ///
    /// Parsing strategy differences from Part 1:
    /// - Within each problem slice, every column forms a number (top digit is most significant).
    /// - The order of problems is right-to-left, but because we add all problem results, processing order is irrelevant.
    ///
    /// Time Complexity: O(r * c) to build the worksheet plus O(p * w * r) where w is max slice width (columns per problem)
    /// Space Complexity: O(r * c) for the padded worksheet and O(p * w) for parsed numbers
    func part2() -> Int {
        let problems = parseColumnarProblems()
        guard !problems.isEmpty else { return 0 }

        var total = 0

        for problem in problems {
            guard !problem.numbers.isEmpty else { continue }

            let value: Int
            switch problem.operation {
            case "+":
                value = problem.numbers.reduce(0, +)
            case "*":
                value = problem.numbers.reduce(1, *)
            default:
                continue
            }

            total += value
        }

        return total
    }

    private struct Problem {
        let numbers: [Int]
        let operation: Character
    }

    private func parseVerticalProblems() -> [Problem] {
        guard let worksheet = buildWorksheet() else { return [] }

        let operatorLine = worksheet.padded[worksheet.operatorRow]
        var problems: [Problem] = []
        problems.reserveCapacity(worksheet.slices.count)

        for (start, end) in worksheet.slices {
            let operatorSlice = substring(from: operatorLine, start: start, end: end)
            guard let operation = operatorSlice.trimmingCharacters(in: .whitespaces).first else { continue }

            var numbers: [Int] = []
            numbers.reserveCapacity(worksheet.operatorRow)

            for row in 0..<worksheet.operatorRow {
                let slice = substring(from: worksheet.padded[row], start: start, end: end)
                let trimmed = slice.trimmingCharacters(in: .whitespaces)
                if let value = Int(trimmed) {
                    numbers.append(value)
                }
            }

            problems.append(Problem(numbers: numbers, operation: operation))
        }

        return problems
    }

    private func parseColumnarProblems() -> [Problem] {
        guard let worksheet = buildWorksheet() else { return [] }

        let operatorLine = worksheet.padded[worksheet.operatorRow]
        var problems: [Problem] = []
        problems.reserveCapacity(worksheet.slices.count)

        for (start, end) in worksheet.slices {
            let operatorSlice = substring(from: operatorLine, start: start, end: end)
            guard let operation = operatorSlice.trimmingCharacters(in: .whitespaces).first else { continue }

            var numbers: [Int] = []
            numbers.reserveCapacity(end - start + 1)

            for col in start...end {
                var digits = ""
                digits.reserveCapacity(worksheet.operatorRow)

                for row in 0..<worksheet.operatorRow {
                    let line = worksheet.padded[row]
                    let index = line.index(line.startIndex, offsetBy: col)
                    let character = line[index]
                    if character != " " {
                        digits.append(character)
                    }
                }

                if let value = Int(digits) {
                    numbers.append(value)
                }
            }

            problems.append(Problem(numbers: numbers, operation: operation))
        }

        return problems
    }

    private struct Worksheet {
        let padded: [String]
        let operatorRow: Int
        let slices: [(Int, Int)]
    }

    private func buildWorksheet() -> Worksheet? {
        let normalized = input.replacingOccurrences(of: "\r\n", with: "\n")
        var lines = normalized.components(separatedBy: "\n")

        while let last = lines.last, last.isEmpty {
            lines.removeLast()
        }

        guard lines.count >= 2 else { return nil }

        let width = lines.map(\.count).max() ?? 0
        let padded: [String] = lines.map { line in
            if line.count < width {
                return line.padding(toLength: width, withPad: " ", startingAt: 0)
            }
            return line
        }

        var separator = Array(repeating: true, count: width)
        for col in 0..<width {
            for row in 0..<padded.count {
                let line = padded[row]
                let index = line.index(line.startIndex, offsetBy: col)
                if line[index] != " " {
                    separator[col] = false
                    break
                }
            }
        }

        var slices: [(Int, Int)] = []
        var col = 0
        while col < width {
            if separator[col] {
                col += 1
                continue
            }
            let start = col
            while col < width && !separator[col] {
                col += 1
            }
            slices.append((start, col - 1))
        }

        let operatorRow = padded.count - 1
        return Worksheet(padded: padded, operatorRow: operatorRow, slices: slices)
    }

    private func substring(from line: String, start: Int, end: Int) -> String {
        guard start < line.count else { return "" }
        let limitedEnd = min(end, line.count - 1)
        let startIndex = line.index(line.startIndex, offsetBy: start)
        let endIndex = line.index(line.startIndex, offsetBy: limitedEnd)
        return String(line[startIndex...endIndex])
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

        let day = Day06(input: input)

        print("Day 06 - Trash Compactor")
        print("========================")
        print("Part 1: \(day.part1())")
        print("Part 2: \(day.part2())")
    }
}
