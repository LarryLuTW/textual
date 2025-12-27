import Foundation

// MARK: - Overview
//
// `MarkdownPreprocessor` performs a lightweight, text-level pass over Markdown before Foundation
// parses it into an `AttributedString`.
//
// This is used for features that Foundation’s Markdown parsing doesn’t support directly, like
// expanding `:shortcode:` sequences into custom placeholders.
//
// Foundation supports custom attributes in Markdown through Apple’s extension syntax:
// `^[text](attribute1: value1, attribute2: value2, ...)`. Textual uses that mechanism to embed
// Textual-defined attributes into the source Markdown. When the Markdown is later parsed,
// Foundation emits runs carrying those attributes.

struct MarkdownPreprocessor {
  private let emoji: [String: Emoji]
  private let tokenizer: MarkupTokenizer

  init(emoji: Set<Emoji>) {
    self.emoji = Dictionary(
      uniqueKeysWithValues: emoji.map { emoji in
        (emoji.shortcode, emoji)
      }
    )
    self.tokenizer = MarkupTokenizer(patterns: emoji.isEmpty ? [] : [.emoji])
  }

  func expand(markdown: String) throws -> String {
    try tokenizer.tokenize(markdown).map { token in
      switch token.type {
      case .emoji:
        guard let shortcode = token.capturedContent, let emoji = emoji[shortcode] else {
          return token.content
        }
        let name = AttributeScopes.TextualAttributes.EmojiURLAttribute.name
        return "^[\(shortcode)]('\(name)': '\(emoji.url)')"
      default:
        return token.content
      }
    }.joined()
  }
}
