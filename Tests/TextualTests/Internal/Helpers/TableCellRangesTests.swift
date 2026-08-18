import SwiftUI
import Testing

@testable import Textual

extension AttributedString {
  struct TableCellRangesTests {
    @Test func emptyCellsKeepTheirColumn() throws {
      // given
      let attributedString = try AttributedString(
        markdown: """
          |  | Col A | Col B |
          | --- | --- | --- |
          | Row 1 |  | b |
          """
      )
      let tableBlock = try #require(attributedString.blockRuns().first)
      let table = attributedString[tableBlock.range]
      let rows = table.blockRuns(parent: tableBlock.intent)
      #expect(rows.count == 2)

      // when
      let headerCells = table[rows[0].range]
        .tableCellRanges(rowIntent: rows[0].intent, columnCount: 3)
      let bodyCells = table[rows[1].range]
        .tableCellRanges(rowIntent: rows[1].intent, columnCount: 3)

      // then
      #expect(headerCells.map { String(table[$0].characters[...]) } == ["", "Col A", "Col B"])
      #expect(bodyCells.map { String(table[$0].characters[...]) } == ["Row 1", "", "b"])
    }
  }
}
