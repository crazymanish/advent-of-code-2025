import Testing
@testable import Day06

struct Day06Tests {
    private let exampleInput = """
123 328  51 64
 45 64  387 23
  6 98  215 314
*   +   *   +
"""

    @Test func testPart1Example() {
        let day = Day06(input: exampleInput)
        #expect(day.part1() == 4_277_556)
    }

    @Test func testPart2Example() {
        let day = Day06(input: exampleInput)
        #expect(day.part2() == 3_263_827)
    }
}
