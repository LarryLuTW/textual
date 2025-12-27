import Foundation
import SnapshotTesting
import Testing

@testable import Textual

struct MarkdownPreprocessorTests {
  @Test func emoji() throws {
    // given
    let markdownPreprocessor = MarkdownPreprocessor(emoji: .previewEmoji)

    // when
    let result = try markdownPreprocessor.expand(
      markdown: """
        **Working late on the new feature** has been surprisingly fun—_even when the build \
        fails_ :confused_dog:, a quick refactor usually gets things back on track :doge:, \
        and when it doesn’t, I just roll with it :dogroll: until the solution finally \
        clicks (though sometimes I still end up a bit :sad_dog:).
        """
    )

    // then
    assertSnapshot(of: result, as: .description)
  }
}
