import Foundation
import Testing

@testable import Textual

struct MarkupTokenizerTests {
  @Test func markup() throws {
    // given
    let markupTokenizer = MarkupTokenizer(patterns: [.emoji])

    // when
    let tokens = try markupTokenizer.tokenize("Hello world")

    // then
    #expect(
      tokens == [
        .init(type: .markup, content: "Hello world")
      ]
    )
  }

  @Test func emoji() throws {
    // given
    let markupTokenizer = MarkupTokenizer(patterns: [.emoji])

    // when
    let tokens = try markupTokenizer.tokenize("Hello :smile: and :heart: world")

    // then
    #expect(
      tokens == [
        .init(type: .markup, content: "Hello "),
        .init(type: .emoji, content: ":smile:", capturedContent: "smile"),
        .init(type: .markup, content: " and "),
        .init(type: .emoji, content: ":heart:", capturedContent: "heart"),
        .init(type: .markup, content: " world"),
      ]
    )
  }

  @Test func adjacentEmoji() throws {
    // given
    let markupTokenizer = MarkupTokenizer(patterns: [.emoji])

    // when
    let tokens = try markupTokenizer.tokenize("Hello :smile::heart: world")

    // then
    #expect(
      tokens == [
        .init(type: .markup, content: "Hello "),
        .init(type: .emoji, content: ":smile:", capturedContent: "smile"),
        .init(type: .emoji, content: ":heart:", capturedContent: "heart"),
        .init(type: .markup, content: " world"),
      ]
    )
  }

  @Test func incompleteEmoji() throws {
    // given
    let markupTokenizer = MarkupTokenizer(patterns: [.emoji])

    // when
    let tokens = try markupTokenizer.tokenize("Hello :smile")

    // then
    #expect(
      tokens == [
        .init(type: .markup, content: "Hello :smile")
      ]
    )
  }

  @Test func emptyEmoji() throws {
    // given
    let markupTokenizer = MarkupTokenizer(patterns: [.emoji])

    // when
    let tokens = try markupTokenizer.tokenize("Hello :: world")

    // then
    #expect(
      tokens == [
        .init(type: .markup, content: "Hello :: world")
      ]
    )
  }

  @Test func invalidEmoji() throws {
    // given
    let markupTokenizer = MarkupTokenizer(patterns: [.emoji])

    // when
    let tokens = try markupTokenizer.tokenize("Hello :not emoji: :notemoji!: world")

    // then
    #expect(
      tokens == [
        .init(type: .markup, content: "Hello :not emoji: :notemoji!: world")
      ]
    )
  }

  @Test func preservesNewlines() throws {
    // given
    let markupTokenizer = MarkupTokenizer(patterns: [.emoji])

    // when
    let tokens = try markupTokenizer.tokenize(
      """
      Some line
      Hello :smile: and :heart: world
      Another line
      """
    )

    // then
    #expect(
      tokens == [
        .init(type: .markup, content: "Some line\nHello "),
        .init(type: .emoji, content: ":smile:", capturedContent: "smile"),
        .init(type: .markup, content: " and "),
        .init(type: .emoji, content: ":heart:", capturedContent: "heart"),
        .init(type: .markup, content: " world\nAnother line"),
      ]
    )
  }

  @Test func markupEmbeddedEmoji() throws {
    // given
    let markupTokenizer = MarkupTokenizer(patterns: [.emoji])

    // when
    let tokens = try markupTokenizer.tokenize("**Bold :smile:** and *italic :heart:*")

    // then
    #expect(
      tokens == [
        .init(type: .markup, content: "**Bold "),
        .init(type: .emoji, content: ":smile:", capturedContent: "smile"),
        .init(type: .markup, content: "** and *italic "),
        .init(type: .emoji, content: ":heart:", capturedContent: "heart"),
        .init(type: .markup, content: "*"),
      ]
    )
  }
}
