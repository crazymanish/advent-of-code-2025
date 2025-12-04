import Testing
@testable import Day04

struct Day04Tests {
    let exampleInput = """
    ..@@.@@@@.
    @@@.@.@.@@
    @@@@@.@.@@
    @.@@@@..@.
    @@.@@@@.@@
    .@@@@@@@.@
    .@.@.@.@@@
    @.@@@.@@@@
    .@@@@@@@@.
    @.@.@@@.@.
    """

    @Test func testPart1Example() {
        let day = Day04(input: exampleInput)
        #expect(day.part1() == 13)
    }

    @Test func testPart2Example() {
        let day = Day04(input: exampleInput)
        #expect(day.part2() == 43)
    }
}
