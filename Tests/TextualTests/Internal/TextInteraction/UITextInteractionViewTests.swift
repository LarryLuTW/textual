#if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(UIKit) && !targetEnvironment(macCatalyst)
  import Foundation
  import Testing
  import UniformTypeIdentifiers

  @testable import Textual

  @MainActor
  struct UITextInteractionViewTests {
    @Test
    func singleLayoutCopyDoesNotRecreateListMarker() throws {
      for markdown in ["1. Moonlight crossed", "- Moonlight crossed"] {
        let attributedText = try NSAttributedString(markdown: markdown)
        let range = (attributedText.string as NSString).range(of: "Moonlight crossed")
        let selectedText = attributedText.attributedSubstring(from: range)

        let item = UITextInteractionView.clipboardItem(
          for: selectedText,
          spansMultipleLayouts: false
        )

        #expect(item[UTType.plainText.identifier] as? String == "Moonlight crossed")
        #expect(item[UTType.html.identifier] == nil)
      }
    }

    @Test
    func multipleLayoutCopyPreservesListFormatting() throws {
      let attributedText = try NSAttributedString(markdown: "1. Moonlight crossed")

      let item = UITextInteractionView.clipboardItem(
        for: attributedText,
        spansMultipleLayouts: true
      )

      #expect(item[UTType.plainText.identifier] as? String == "  1. Moonlight crossed")
      #expect(item[UTType.html.identifier] as? String == "<ol>\n<li>Moonlight crossed</li>\n</ol>")
    }
  }
#endif
