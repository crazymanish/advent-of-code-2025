import Foundation

struct Day10 {
    let input: String

    init(input: String) {
        self.input = input
    }

    // MARK: - Parsing

    struct Machine {
        let targetLights: [Bool]  // Desired indicator light pattern
        let buttons: [[Int]]      // Each button lists which lights or counters it affects
        let joltages: [Int]       // Joltage targets for part 2
    }

    func parseMachines() -> [Machine] {
        return input.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
            .map { parseMachine($0) }
    }

    func parseMachine(_ line: String) -> Machine {
        // Parse indicator light diagram [.##.]
        guard let startBracket = line.firstIndex(of: "["),
              let endBracket = line.firstIndex(of: "]") else {
            fatalError("Invalid machine format: \(line)")
        }
        let lightPattern = String(line[line.index(after: startBracket)..<endBracket])
        let targetLights = lightPattern.map { $0 == "#" }

        // Parse button wiring schematics (0,2,3) or (3)
        var buttons: [[Int]] = []
        var searchStart = endBracket

        while let parenStart = line[searchStart...].firstIndex(of: "("),
              let parenEnd = line[parenStart...].firstIndex(of: ")") {
            let content = String(line[line.index(after: parenStart)..<parenEnd])
            let toggles = content.components(separatedBy: ",").compactMap { Int($0) }
            buttons.append(toggles)
            searchStart = parenEnd
        }

        // Parse joltage requirements {3,5,4,7}
        var joltages: [Int] = []
        if let braceStart = line.firstIndex(of: "{"),
           let braceEnd = line.firstIndex(of: "}") {
            let content = String(line[line.index(after: braceStart)..<braceEnd])
            joltages = content.components(separatedBy: ",").compactMap { Int($0) }
        }

        return Machine(targetLights: targetLights, buttons: buttons, joltages: joltages)
    }

    // MARK: - Part 1: Minimum button presses using GF(2) linear algebra

    /// Part 1: Find minimum button presses to configure all machines
    ///
    /// This is a system of linear equations over GF(2) (binary field).
    /// Each button toggles specific lights (XOR), and pressing twice cancels out.
    /// We need to find minimum-weight solution vector.
    ///
    /// Time Complexity: O(M * (n^2 * m + 2^m)) where M = number of machines,
    ///                  n = number of lights, m = number of buttons
    /// Space Complexity: O(n * m) for the augmented matrix
    func part1() -> Int {
        let machines = parseMachines()
        return machines.map { minPresses(for: $0) }.reduce(0, +)
    }

    /// Find minimum button presses for a single machine
    func minPresses(for machine: Machine) -> Int {
        let numLights = machine.targetLights.count
        let numButtons = machine.buttons.count

        // Build augmented matrix [A | b] where A is button effects, b is target
        // Each row represents one light, each column represents one button
        // Entry A[i][j] = 1 if button j toggles light i
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: numButtons + 1), count: numLights)

        for (buttonIdx, toggles) in machine.buttons.enumerated() {
            for lightIdx in toggles {
                if lightIdx < numLights {
                    matrix[lightIdx][buttonIdx] = 1
                }
            }
        }

        // Add target column (last column)
        for (lightIdx, isOn) in machine.targetLights.enumerated() {
            matrix[lightIdx][numButtons] = isOn ? 1 : 0
        }

        // Gaussian elimination over GF(2) to get reduced row echelon form
        var pivotCol = 0
        var pivotRow = 0
        var pivotColumns = [Int]()  // Track which columns have pivots

        while pivotRow < numLights && pivotCol < numButtons {
            // Find pivot in current column
            var found = -1
            for row in pivotRow..<numLights {
                if matrix[row][pivotCol] == 1 {
                    found = row
                    break
                }
            }

            if found == -1 {
                // No pivot in this column, it's a free variable
                pivotCol += 1
                continue
            }

            // Swap rows
            if found != pivotRow {
                matrix.swapAt(pivotRow, found)
            }

            pivotColumns.append(pivotCol)

            // Eliminate all other 1s in this column
            for row in 0..<numLights {
                if row != pivotRow && matrix[row][pivotCol] == 1 {
                    for col in 0...numButtons {
                        matrix[row][col] ^= matrix[pivotRow][col]
                    }
                }
            }

            pivotRow += 1
            pivotCol += 1
        }

        // Check for inconsistency: row with all zeros except last column = 1
        for row in pivotRow..<numLights {
            if matrix[row][numButtons] == 1 {
                // No solution exists
                return Int.max
            }
        }

        // Find free variables (columns without pivots)
        let pivotSet = Set(pivotColumns)
        var freeVars = [Int]()
        for col in 0..<numButtons {
            if !pivotSet.contains(col) {
                freeVars.append(col)
            }
        }

        // Try all combinations of free variables to find minimum weight solution
        let numFree = freeVars.count
        var minPresses = Int.max

        for mask in 0..<(1 << numFree) {
            var solution = [Int](repeating: 0, count: numButtons)

            // Set free variables according to mask
            for (i, freeCol) in freeVars.enumerated() {
                solution[freeCol] = (mask >> i) & 1
            }

            // Back-substitute to find pivot variables
            for (rowIdx, pivotColIdx) in pivotColumns.enumerated().reversed() {
                var val = matrix[rowIdx][numButtons]
                for col in (pivotColIdx + 1)..<numButtons {
                    val ^= (matrix[rowIdx][col] * solution[col])
                }
                solution[pivotColIdx] = val
            }

            // Count number of button presses (1s in solution)
            let presses = solution.reduce(0, +)
            minPresses = min(minPresses, presses)
        }

        return minPresses
    }

    // MARK: - Part 2: Minimum presses for joltage configuration

    /// Part 2: Find minimum button presses to configure joltage counters
    ///
    /// This is an Integer Linear Programming problem:
    /// - Each button press adds 1 to specific counters
    /// - Find non-negative integers x_i (button presses) minimizing sum(x_i)
    /// - Subject to: A*x = b where A[i][j] = 1 if button j affects counter i
    ///
    /// We solve using Gaussian elimination to find the general solution,
    /// then minimize over the free parameters.
    ///
    /// Time Complexity: O(M * n^2 * m) for Gaussian elimination + optimization
    /// Space Complexity: O(n * m) for the matrix
    func part2() -> Int {
        let machines = parseMachines()
        return machines.map { minJoltagePresses(for: $0) }.reduce(0, +)
    }

    /// Find minimum button presses for joltage configuration using linear algebra
    func minJoltagePresses(for machine: Machine) -> Int {
        let numCounters = machine.joltages.count
        let numButtons = machine.buttons.count

        // Build augmented matrix [A | b] over rationals
        // Each row = counter, each column = button
        // A[i][j] = 1 if button j affects counter i
        var matrix = [[Double]](repeating: [Double](repeating: 0, count: numButtons + 1), count: numCounters)

        for (buttonIdx, affects) in machine.buttons.enumerated() {
            for counterIdx in affects {
                if counterIdx < numCounters {
                    matrix[counterIdx][buttonIdx] = 1.0
                }
            }
        }

        // Target column
        for (i, target) in machine.joltages.enumerated() {
            matrix[i][numButtons] = Double(target)
        }

        // Gaussian elimination with partial pivoting to RREF
        var pivotRow = 0
        var pivotColumns = [Int]()

        for col in 0..<numButtons {
            // Find pivot (largest absolute value)
            var maxRow = pivotRow
            for row in (pivotRow + 1)..<numCounters {
                if abs(matrix[row][col]) > abs(matrix[maxRow][col]) {
                    maxRow = row
                }
            }

            if abs(matrix[maxRow][col]) < 1e-10 {
                continue  // No pivot in this column
            }

            // Swap rows
            if maxRow != pivotRow {
                matrix.swapAt(pivotRow, maxRow)
            }

            pivotColumns.append(col)

            // Scale pivot row
            let scale = matrix[pivotRow][col]
            for c in col...numButtons {
                matrix[pivotRow][c] /= scale
            }

            // Eliminate other rows
            for row in 0..<numCounters {
                if row != pivotRow && abs(matrix[row][col]) > 1e-10 {
                    let factor = matrix[row][col]
                    for c in col...numButtons {
                        matrix[row][c] -= factor * matrix[pivotRow][c]
                    }
                }
            }

            pivotRow += 1
            if pivotRow >= numCounters {
                break
            }
        }

        // Check for inconsistency
        for row in pivotRow..<numCounters {
            if abs(matrix[row][numButtons]) > 1e-10 {
                return Int.max  // No solution
            }
        }

        // Free variables (columns without pivots)
        let pivotSet = Set(pivotColumns)
        var freeVars = [Int]()
        for col in 0..<numButtons {
            if !pivotSet.contains(col) {
                freeVars.append(col)
            }
        }

        let numFree = freeVars.count

        // Pivot variables are expressed as: pivot = constant - sum(coef * freeVar)

        // Evaluate a solution given free variable values
        func evaluateSolution(freeVals: [Int]) -> (valid: Bool, total: Int) {
            var total = freeVals.reduce(0, +)

            for (rowIdx, _) in pivotColumns.enumerated() {
                var val = matrix[rowIdx][numButtons]
                for (freeIdx, freeCol) in freeVars.enumerated() {
                    val -= matrix[rowIdx][freeCol] * Double(freeVals[freeIdx])
                }
                let intVal = Int(round(val))
                if intVal < 0 || abs(val - Double(intVal)) > 1e-6 {
                    return (false, Int.max)
                }
                total += intVal
            }
            return (true, total)
        }

        if numFree == 0 {
            let (valid, total) = evaluateSolution(freeVals: [])
            return valid ? total : Int.max
        }

        // Per-button caps: a button can't be pressed more than the smallest
        // target of any counter it touches (presses only add to counters).
        var buttonCaps = [Int](repeating: 0, count: numButtons)
        for (buttonIdx, affects) in machine.buttons.enumerated() {
            var cap = Int.max
            for c in affects {
                if c < machine.joltages.count {
                    cap = min(cap, machine.joltages[c])
                }
            }
            buttonCaps[buttonIdx] = cap == Int.max ? 0 : cap
        }

        // Fallback bound for rare cases where every cap is zero
        let maxTarget = machine.joltages.max() ?? 0
        let globalCap = maxTarget > 0 ? maxTarget : 50

        var minPresses = Int.max

        // For small number of free variables, do exhaustive search with pruning
        if numFree <= 4 {
            func search(_ freeIdx: Int, _ freeVals: inout [Int], _ currentSum: Int) {
                if currentSum >= minPresses {
                    return  // Prune
                }

                if freeIdx == numFree {
                    let (valid, total) = evaluateSolution(freeVals: freeVals)
                    if valid {
                        minPresses = min(minPresses, total)
                    }
                    return
                }

                // Bound for this free variable is the cap of that button (freeVars maps to column)
                let buttonCap = buttonCaps[freeVars[freeIdx]]
                let localUpper = buttonCap > 0 ? buttonCap : globalCap

                for v in 0...localUpper {
                    if currentSum + v >= minPresses { break }
                    freeVals[freeIdx] = v
                    search(freeIdx + 1, &freeVals, currentSum + v)
                }
            }

            var freeVals = [Int](repeating: 0, count: numFree)
            search(0, &freeVals, 0)
        } else {
            // For larger problems, sample different starting points within bounds
            let samples = min(1 << numFree, 512)
            for startMask in 0..<samples {
                var freeVals = [Int](repeating: 0, count: numFree)
                for i in 0..<numFree {
                    let cap = buttonCaps[freeVars[i]] > 0 ? buttonCaps[freeVars[i]] : globalCap
                    freeVals[i] = ((startMask >> i) & 1) * min(cap, maxTarget)
                }

                // Local search to improve within bounds
                var improved = true
                while improved {
                    improved = false
                    for i in 0..<numFree {
                        let cap = buttonCaps[freeVars[i]] > 0 ? buttonCaps[freeVars[i]] : globalCap

                        if freeVals[i] < cap {
                            freeVals[i] += 1
                            let (valid1, total1) = evaluateSolution(freeVals: freeVals)
                            if valid1 && total1 < minPresses {
                                minPresses = total1
                                improved = true
                            }
                        }

                        if freeVals[i] > 0 {
                            freeVals[i] -= 1
                            let (valid2, total2) = evaluateSolution(freeVals: freeVals)
                            if valid2 && total2 < minPresses {
                                minPresses = total2
                                improved = true
                            }
                        }
                    }
                }

                let (valid, total) = evaluateSolution(freeVals: freeVals)
                if valid {
                    minPresses = min(minPresses, total)
                }
            }
        }

        return minPresses
    }
}

// MARK: - Main Entry Point

@main
struct Main {
    static func main() {
        guard let inputURL = Bundle.module.url(forResource: "input", withExtension: "txt"),
              let input = try? String(contentsOf: inputURL, encoding: .utf8) else {
            print("Error: Could not load input.txt")
            return
        }

        let day = Day10(input: input)

        print("Day 10 - Factory")
        print("========================")
        print("Part 1: \(day.part1())")
        print("Part 2: \(day.part2())")
    }
}
