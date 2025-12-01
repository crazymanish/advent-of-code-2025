import Testing
@testable import Day01

@Suite("Day01 Tests")
struct Day01Tests {

    @Test("Part 1 - Example from puzzle description")
    func testPart1Example() {
        let exampleInput = """
        L68
        L30
        R48
        L5
        R60
        L55
        L1
        L99
        R14
        L82
        """

        let day = Day01(input: exampleInput)
        #expect(day.part1() == 3)
    }

    @Test("Part 1 - Single rotation to zero")
    func testPart1SingleZero() {
        // Start at 50, L50 -> 0
        let input = "L50"
        let day = Day01(input: input)
        #expect(day.part1() == 1)
    }

    @Test("Part 1 - Wrap around from low to high")
    func testPart1WrapLowToHigh() {
        // Start at 50, L55 -> 95 (wraps around)
        let input = "L55"
        let day = Day01(input: input)
        #expect(day.part1() == 0)
    }

    @Test("Part 1 - Wrap around from high to low")
    func testPart1WrapHighToLow() {
        // Start at 50, R50 -> 0 (wraps around from 100)
        let input = "R50"
        let day = Day01(input: input)
        #expect(day.part1() == 1)
    }

    @Test("Part 1 - No zeros")
    func testPart1NoZeros() {
        let input = """
        R10
        L5
        R3
        """
        let day = Day01(input: input)
        #expect(day.part1() == 0)
    }

    // MARK: - Part 2 Tests

    @Test("Part 2 - Example from puzzle description")
    func testPart2Example() {
        let exampleInput = """
        L68
        L30
        R48
        L5
        R60
        L55
        L1
        L99
        R14
        L82
        """

        let day = Day01(input: exampleInput)
        // 3 times at end of rotation + 3 times during rotation = 6
        #expect(day.part2() == 6)
    }

    @Test("Part 2 - R1000 from position 50 crosses 0 ten times")
    func testPart2LargeRotation() {
        // Start at 50, R1000 -> crosses 0 at clicks 50, 150, 250, 350, 450, 550, 650, 750, 850, 950
        let input = "R1000"
        let day = Day01(input: input)
        #expect(day.part2() == 10)
    }

    @Test("Part 2 - Single rotation crossing zero once")
    func testPart2SingleCrossing() {
        // Start at 50, L68 -> crosses 0 once (at click 50)
        let input = "L68"
        let day = Day01(input: input)
        #expect(day.part2() == 1)
    }

    @Test("Part 2 - Rotation landing exactly on zero")
    func testPart2ExactZero() {
        // Start at 50, L50 -> lands on 0, counted once
        let input = "L50"
        let day = Day01(input: input)
        #expect(day.part2() == 1)
    }

    @Test("Part 2 - No zero crossings")
    func testPart2NoZeroCrossings() {
        // Start at 50, L10 -> goes to 40, never passes 0
        let input = "L10"
        let day = Day01(input: input)
        #expect(day.part2() == 0)
    }

    @Test("Part 2 - Multiple full rotations left")
    func testPart2MultipleFullRotationsLeft() {
        // Start at 50, L250 -> crosses 0 at clicks 50, 150, 250 = 3 times
        let input = "L250"
        let day = Day01(input: input)
        #expect(day.part2() == 3)
    }
}
