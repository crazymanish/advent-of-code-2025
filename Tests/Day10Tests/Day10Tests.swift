import Testing
@testable import Day10

struct Day10Tests {
    private let exampleInput = """
    [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
    [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
    [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
    """

    @Test func testPart1Example() {
        let day = Day10(input: exampleInput)
        #expect(day.part1() == 7)
    }

    @Test func testMachine1() {
        let input = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}"
        let day = Day10(input: input)
        #expect(day.part1() == 2)
    }

    @Test func testMachine2() {
        let input = "[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}"
        let day = Day10(input: input)
        #expect(day.part1() == 3)
    }

    @Test func testMachine3() {
        let input = "[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"
        let day = Day10(input: input)
        #expect(day.part1() == 2)
    }

    @Test func testPart2Example() {
        let day = Day10(input: exampleInput)
        #expect(day.part2() == 33)
    }

    @Test func testJoltageMachine1() {
        let input = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}"
        let day = Day10(input: input)
        #expect(day.part2() == 10)
    }

    @Test func testJoltageMachine2() {
        let input = "[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}"
        let day = Day10(input: input)
        #expect(day.part2() == 12)
    }

    @Test func testJoltageMachine3() {
        let input = "[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"
        let day = Day10(input: input)
        #expect(day.part2() == 11)
    }
}
