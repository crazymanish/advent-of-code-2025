import Testing
@testable import Day05

struct Day05Tests {
    private let exampleInput = """
    3-5
    10-14
    16-20
    12-18

    1
    5
    8
    11
    17
    32
    """

    @Test func testPart1Example() {
        let day = Day05(input: exampleInput)
        #expect(day.part1() == 3)
    }

    @Test func testPart2Example() {
        let day = Day05(input: exampleInput)
        #expect(day.part2() == 14)
    }
}
