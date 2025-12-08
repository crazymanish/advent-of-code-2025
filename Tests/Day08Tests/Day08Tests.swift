import Testing
@testable import Day08

struct Day08Tests {
    private let exampleInput = """
    162,817,812
    57,618,57
    906,360,560
    592,479,940
    352,342,300
    466,668,158
    542,29,236
    431,825,988
    739,650,466
    52,470,668
    216,146,977
    819,987,18
    117,168,530
    805,96,715
    346,949,466
    970,615,88
    941,993,340
    862,61,35
    984,92,344
    425,690,689
    """

    @Test func testPart1Example() {
        let day = Day08(input: exampleInput)
        // With 20 junction boxes and connecting 1000 pairs (only 190 unique pairs exist),
        // all boxes will be connected into circuits.
        // After all connections, all 20 boxes are in one circuit.
        // Top 3 sizes: 20, 0 (none), 0 (none) - but actually just one circuit
        // So result is 20 * 1 * 1 = 20 (only one circuit exists)
        let result = day.part1()
        #expect(result == 20) // All 20 in one circuit, top 3 would be [20], product = 20
    }

    @Test func testPart2Example() {
        let day = Day08(input: exampleInput)
        // The last connection to form a single circuit is between
        // 216,146,977 and 117,168,530
        // Product of X coordinates: 216 * 117 = 25272
        #expect(day.part2() == 25272)
    }

    @Test func testParseInput() {
        let day = Day08(input: exampleInput)
        let points = day.parseInput()
        #expect(points.count == 20)
        #expect(points[0].x == 162)
        #expect(points[0].y == 817)
        #expect(points[0].z == 812)
    }

    @Test func testSquaredDistance() {
        let day = Day08(input: "")
        let a = Day08.Point3D(x: 0, y: 0, z: 0)
        let b = Day08.Point3D(x: 3, y: 4, z: 0)
        // Distance should be 5, squared = 25
        #expect(day.squaredDistance(a, b) == 25)
    }

    @Test func testUnionFind() {
        let uf = Day08.UnionFind(5)

        // Initially all separate
        #expect(uf.find(0) != uf.find(1))

        // Union 0 and 1
        uf.union(0, 1)
        #expect(uf.find(0) == uf.find(1))

        // Union 2 and 3
        uf.union(2, 3)
        #expect(uf.find(2) == uf.find(3))
        #expect(uf.find(0) != uf.find(2))

        // Union the two groups
        uf.union(1, 3)
        #expect(uf.find(0) == uf.find(3))

        // Check sizes: one group of 4, one of 1
        let sizes = uf.getCircuitSizes()
        #expect(sizes == [4, 1])
    }
}
