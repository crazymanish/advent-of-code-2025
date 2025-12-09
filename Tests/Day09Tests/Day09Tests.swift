import Testing
@testable import Day09

struct Day09Tests {
    private let exampleInput = """
    7,1
    11,1
    11,7
    9,7
    9,5
    2,5
    2,3
    7,3
    """

    @Test func testPart1Example() {
        let day = Day09(input: exampleInput)
        #expect(day.part1() == 50)
    }

    @Test func testPart2Example() {
        let day = Day09(input: exampleInput)
        #expect(day.part2() == 24)
    }
}
