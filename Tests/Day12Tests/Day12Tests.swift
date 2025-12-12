import Testing
@testable import Day12

struct Day12Tests {
    private let exampleInput = """
    0:
    ###
    ##.
    ##.

    1:
    ###
    ##.
    .##

    2:
    .##
    ###
    ##.

    3:
    ##.
    ###
    ##.

    4:
    ###
    #..
    ###

    5:
    ###
    .#.
    ###

    4x4: 0 0 0 0 2 0
    12x5: 1 0 1 0 2 2
    12x5: 1 0 1 0 3 2
    """

    @Test func testPart1Example() {
        let day = Day12(input: exampleInput)
        #expect(day.part1() == 2)
    }
}
