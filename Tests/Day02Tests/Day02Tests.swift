import Testing
import Foundation
@testable import Day02

@Suite("Day02 Tests")
struct Day02Tests {

    @Test("Part 1 - Example from puzzle description")
    func testPart1Example() {
        let exampleInput = """
        11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
        """

        let day = Day02(input: exampleInput)
        #expect(day.part1() == 1227775554)
    }

    @Test("Invalid ID detection - Single digit repeated")
    func testInvalidIDSingleDigit() {
        // Range containing 11, 22, 33, etc.
        let input = "10-25"
        let day = Day02(input: input)
        // 11 and 22 are invalid
        #expect(day.part1() == 33)  // 11 + 22
    }

    @Test("Invalid ID detection - Two digits repeated")
    func testInvalidIDTwoDigits() {
        // Range containing 6464
        let input = "6460-6470"
        let day = Day02(input: input)
        #expect(day.part1() == 6464)
    }

    @Test("Invalid ID detection - Three digits repeated")
    func testInvalidIDThreeDigits() {
        // Range containing 123123
        let input = "123120-123130"
        let day = Day02(input: input)
        #expect(day.part1() == 123123)
    }

    @Test("No invalid IDs in range")
    func testNoInvalidIDs() {
        // 1698522-1698528 contains no invalid IDs
        let input = "1698522-1698528"
        let day = Day02(input: input)
        #expect(day.part1() == 0)
    }

    @Test("Range with 99 invalid ID")
    func testRange99() {
        // 95-115 has one invalid ID: 99
        let input = "95-115"
        let day = Day02(input: input)
        #expect(day.part1() == 99)
    }

    @Test("Range with 1010 invalid ID")
    func testRange1010() {
        // 998-1012 has one invalid ID: 1010
        let input = "998-1012"
        let day = Day02(input: input)
        #expect(day.part1() == 1010)
    }

    @Test("Part 1 - Solution with real input")
    func testPart1Solution() {
        let inputPath = Bundle.module.path(forResource: "input", ofType: "txt")!
        let input = try! String(contentsOfFile: inputPath, encoding: .utf8)

        let day = Day02(input: input)
        let result = day.part1()
        print("Part 1 Solution: \(result)")
        #expect(result > 0)  // Should produce a positive result
    }

    // MARK: - Part 2 Tests

    @Test("Part 2 - Example from puzzle description")
    func testPart2Example() {
        let exampleInput = """
        11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
        """

        let day = Day02(input: exampleInput)
        #expect(day.part2() == 4174379265)
    }

    @Test("Part 2 - Range with 111 (1 repeated 3 times)")
    func testPart2Range111() {
        // 95-115 now has two invalid IDs: 99 and 111
        let input = "95-115"
        let day = Day02(input: input)
        #expect(day.part2() == 210)  // 99 + 111
    }

    @Test("Part 2 - Range with 999 (1 repeated 3 times)")
    func testPart2Range999() {
        // 998-1012 now has two invalid IDs: 999 and 1010
        let input = "998-1012"
        let day = Day02(input: input)
        #expect(day.part2() == 2009)  // 999 + 1010
    }

    @Test("Part 2 - Detects 3 repetitions")
    func testPart2ThreeRepetitions() {
        // Range containing 123123123 (123 repeated 3 times)
        let input = "123123120-123123130"
        let day = Day02(input: input)
        #expect(day.part2() == 123123123)
    }

    @Test("Part 2 - Detects multiple repetition patterns")
    func testPart2MultiplePatterns() {
        // 1111 can be seen as 1×4 or 11×2, but should only be counted once
        let input = "1110-1115"
        let day = Day02(input: input)
        #expect(day.part2() == 1111)
    }

    @Test("Part 2 - Solution with real input")
    func testPart2Solution() {
        let inputPath = Bundle.module.path(forResource: "input", ofType: "txt")!
        let input = try! String(contentsOfFile: inputPath, encoding: .utf8)

        let day = Day02(input: input)
        let result = day.part2()
        print("Part 2 Solution: \(result)")
        #expect(result > 0)  // Should produce a positive result
    }
}
