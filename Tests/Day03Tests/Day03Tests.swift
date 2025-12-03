import Testing
@testable import Day03

struct Day03Tests {

    let exampleInput = """
    987654321111111
    811111111111119
    234234234234278
    818181911112111
    """

    @Test func testPart1Example() {
        let day = Day03(input: exampleInput)
        #expect(day.part1() == 357)
    }

    @Test func testMaxJoltageFromBank() {
        let day = Day03(input: "")

        // Test case 1: 987654321111111 -> 98 (first two digits)
        #expect(day.maxJoltageFromBank("987654321111111") == 98)

        // Test case 2: 811111111111119 -> 89 (8 and 9)
        #expect(day.maxJoltageFromBank("811111111111119") == 89)

        // Test case 3: 234234234234278 -> 78 (last two digits)
        #expect(day.maxJoltageFromBank("234234234234278") == 78)

        // Test case 4: 818181911112111 -> 92 (9 and the 2 after it)
        #expect(day.maxJoltageFromBank("818181911112111") == 92)
    }

    @Test func testSimpleCases() {
        let day = Day03(input: "")

        // Simple ascending
        #expect(day.maxJoltageFromBank("12345") == 45)

        // Simple descending
        #expect(day.maxJoltageFromBank("54321") == 54)

        // Two digits
        #expect(day.maxJoltageFromBank("19") == 19)
        #expect(day.maxJoltageFromBank("91") == 91)

        // All same digits
        #expect(day.maxJoltageFromBank("11111") == 11)
        #expect(day.maxJoltageFromBank("99999") == 99)
    }

    @Test func testPart2Example() {
        let day = Day03(input: exampleInput)
        #expect(day.part2() == 3121910778619)
    }

    @Test func testMaxJoltageFromBankPart2() {
        let day = Day03(input: "")

        // Test case 1: 987654321111111 -> 987654321111
        #expect(day.maxJoltageFromBank("987654321111111", selectCount: 12) == 987654321111)

        // Test case 2: 811111111111119 -> 811111111119
        #expect(day.maxJoltageFromBank("811111111111119", selectCount: 12) == 811111111119)

        // Test case 3: 234234234234278 -> 434234234278
        #expect(day.maxJoltageFromBank("234234234234278", selectCount: 12) == 434234234278)

        // Test case 4: 818181911112111 -> 888911112111
        #expect(day.maxJoltageFromBank("818181911112111", selectCount: 12) == 888911112111)
    }
}
