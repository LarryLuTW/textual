import Testing

@testable import Textual

struct MathComplexityTests {
  @Test func acceptsConventionalNotation() {
    #expect(MathComplexity.isWithinBudget("E = mc^2"))
    #expect(MathComplexity.isWithinBudget("\\int_{0}^{1} x^2\\,dx = \\frac{1}{3}"))
    #expect(MathComplexity.isWithinBudget("\\left( a + b \\right)^2 = a^2 + 2ab + b^2"))
    #expect(MathComplexity.isWithinBudget("\\begin{pmatrix} 1 & 2 \\\\ 3 & 4 \\end{pmatrix}"))
    #expect(MathComplexity.isWithinBudget(""))
  }

  @Test func acceptsLongButShallowExpressions() {
    // A wide matrix is large and legitimate. Length alone must not disqualify it.
    let row = Array(repeating: "1 & 2 & 3 & 4", count: 60).joined(separator: " \\\\ ")
    let matrix = "\\begin{pmatrix}\(row)\\end{pmatrix}"

    #expect(matrix.utf8.count > 800)
    #expect(MathComplexity.isWithinBudget(matrix))
  }

  @Test func rejectsDeeplyNestedDelimiters() {
    let depth = MathComplexity.maxNestingDepth + 1
    let latex =
      String(repeating: "\\left(", count: depth) + "x"
      + String(repeating: "\\right)", count: depth)

    #expect(!MathComplexity.isWithinBudget(latex))
  }

  @Test func rejectsDeeplyNestedBracedArguments() {
    // `\frac{`, `\sqrt{` and `x^{` all nest through a brace, so one rule covers them.
    for command in ["\\frac{", "\\sqrt{", "x^{"] {
      let depth = MathComplexity.maxNestingDepth + 1
      let latex =
        String(repeating: command, count: depth) + "1" + String(repeating: "}", count: depth)

      #expect(!MathComplexity.isWithinBudget(latex), "\(command) should exceed the depth budget")
    }
  }

  @Test func acceptsNestingAtExactlyTheLimit() {
    let latex =
      String(repeating: "\\left(", count: MathComplexity.maxNestingDepth) + "x"
      + String(repeating: "\\right)", count: MathComplexity.maxNestingDepth)

    #expect(MathComplexity.isWithinBudget(latex))
  }

  @Test func rejectsOverlongExpressions() {
    #expect(!MathComplexity.isWithinBudget(String(repeating: "x", count: 4097)))
    #expect(MathComplexity.isWithinBudget(String(repeating: "x", count: 4096)))
  }

  @Test func measuresLengthInUTF8Bytes() {
    // A multi-byte scalar must not let an expression past the byte budget on character count.
    #expect(!MathComplexity.isWithinBudget(String(repeating: "α", count: 2049)))
  }

  @Test func escapedBracesDoNotCountAsNesting() {
    // `\{` is a brace glyph, not a group — repeating it must stay within budget.
    let latex = String(repeating: "\\{", count: MathComplexity.maxNestingDepth * 4)

    #expect(MathComplexity.isWithinBudget(latex))
  }

  @Test func unbalancedClosersDoNotMaskLaterNesting() {
    // Depth must not be driven negative into headroom that hides a deep run afterwards.
    let depth = MathComplexity.maxNestingDepth + 1
    let latex =
      String(repeating: "}", count: 500) + String(repeating: "{", count: depth)

    #expect(!MathComplexity.isWithinBudget(latex))
  }

  @Test func toleratesTrailingBackslash() {
    #expect(MathComplexity.isWithinBudget("x + \\"))
  }
}
