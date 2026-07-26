import Foundation

/// A budget that keeps math typesetting cost proportional to expression size.
///
/// `SwiftUIMath`'s typesetter nests a display node per grouping level, and its cost grows
/// super-linearly in nesting depth — measured at roughly `O(n^2.7)` for `\left(…\right)`,
/// `\frac{…}{…}` and `\sqrt{…}` chains. A few thousand levels take minutes. Because
/// `Math.typographicBounds(for:fitting:font:style:)` is called from `sizeThatFits` during
/// SwiftUI layout, that cost lands on the main thread and presents as an unrecoverable hang
/// rather than a slow draw.
///
/// Markdown is frequently rendered from untrusted sources, so an expression's depth is
/// attacker-chosen. Capping depth restores linear scaling: at `maxNestingDepth` the same
/// content measures 95 ms at 4 KB and 323 ms at 16 KB, i.e. time tracks length.
///
/// Expressions over budget are not rendered as math. Callers fall back to showing the source,
/// which is both cheap and honest about what could not be typeset.
enum MathComplexity {
  /// Deepest grouping nesting that still typesets in bounded time.
  ///
  /// Set far above real usage — conventional notation rarely exceeds ten levels — so the
  /// budget only ever rejects expressions built to be expensive.
  static let maxNestingDepth = 64

  /// Longest accepted expression, in UTF-8 bytes.
  ///
  /// Depth alone bounds the growth rate; this bounds the constant. Together they hold the
  /// worst accepted input to ~155 ms.
  static let maxSourceLength = 4096

  /// Whether `latex` can be typeset within the budget.
  ///
  /// Runs a single linear scan and allocates nothing, so it is safe to call from a `body`.
  static func isWithinBudget(_ latex: String) -> Bool {
    guard latex.utf8.count <= maxSourceLength else {
      return false
    }

    var depth = 0
    var index = latex.startIndex

    while index < latex.endIndex {
      switch latex[index] {
      case "\\":
        let afterBackslash = latex.index(after: index)
        guard afterBackslash < latex.endIndex else {
          return true
        }

        // A backslash followed by a non-letter escapes a literal — `\{` is a brace glyph,
        // not a group — so it must not move the depth.
        guard latex[afterBackslash].isLetter else {
          index = latex.index(after: afterBackslash)
          continue
        }

        var afterCommand = afterBackslash
        while afterCommand < latex.endIndex, latex[afterCommand].isLetter {
          afterCommand = latex.index(after: afterCommand)
        }

        switch latex[afterBackslash..<afterCommand] {
        case "left", "begin":
          depth += 1
        case "right", "end":
          depth = max(0, depth - 1)
        default:
          break
        }

        index = afterCommand
        continue

      case "{":
        // Covers `\frac{`, `\sqrt{`, `x^{` and every other braced argument in one rule.
        depth += 1

      case "}":
        // Clamped, so a run of stray closers cannot drive depth negative and buy
        // headroom for a deep run that follows.
        depth = max(0, depth - 1)

      default:
        break
      }

      if depth > maxNestingDepth {
        return false
      }

      index = latex.index(after: index)
    }

    return true
  }
}
