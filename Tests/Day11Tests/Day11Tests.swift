import Testing
@testable import Day11

struct Day11Tests {
    private let exampleInput = """
    aaa: you hhh
    you: bbb ccc
    bbb: ddd eee
    ccc: ddd eee fff
    ddd: ggg
    eee: out
    fff: out
    ggg: out
    hhh: ccc fff iii
    iii: out
    """

    private let exampleInput2 = """
    svr: aaa bbb
    aaa: fft
    fft: ccc
    bbb: tty
    tty: ccc
    ccc: ddd eee
    ddd: hub
    hub: fff
    eee: dac
    dac: fff
    fff: ggg hhh
    ggg: out
    hhh: out
    """

    @Test func testPart1Example() {
        let day = Day11(input: exampleInput)
        #expect(day.part1() == 5)
    }

    @Test func testPart2Example() {
        let day = Day11(input: exampleInput2)
        #expect(day.part2() == 2)
    }
}
