import Foundation

/// A ``MarkupParser`` implementation backed by Foundation’s Markdown support.
///
/// This parser uses `AttributedString(markdown:...)` under the hood. Use it when your input is
/// Markdown and you want Textual to preserve structure via Foundation attributes such as
/// `PresentationIntent`, inline presentation intents, links, and image URLs.
///
/// Textual also supports a preprocessing step for custom emoji substitution.
public struct AttributedStringMarkdownParser: MarkupParser {
  /// Options that control preprocessing before Markdown parsing.
  public struct PreprocessingOptions: Hashable, Sendable {
    /// A set of custom emoji definitions used to expand `:shortcode:` sequences.
    public var emoji: Set<Emoji>

    /// Creates preprocessing options.
    public init(emoji: Set<Emoji> = []) {
      self.emoji = emoji
    }
  }

  private let baseURL: URL?
  private let options: AttributedString.MarkdownParsingOptions
  private let preprocessor: MarkdownPreprocessor

  public init(
    baseURL: URL?,
    options: AttributedString.MarkdownParsingOptions = .init(),
    preprocessingOptions: PreprocessingOptions = .init()
  ) {
    self.baseURL = baseURL
    self.options = options
    self.preprocessor = MarkdownPreprocessor(emoji: preprocessingOptions.emoji)
  }

  public func attributedString(for input: String) throws -> AttributedString {
    try AttributedString(
      markdown: preprocessor.expand(markdown: input),
      including: \.textual,
      options: options,
      baseURL: baseURL
    )
  }
}

extension MarkupParser where Self == AttributedStringMarkdownParser {
  /// Creates a Markdown parser configured for inline-only syntax.
  public static func inlineMarkdown(
    baseURL: URL? = nil,
    preprocessingOptions: AttributedStringMarkdownParser.PreprocessingOptions = .init()
  ) -> Self {
    .init(
      baseURL: baseURL,
      options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace),
      preprocessingOptions: preprocessingOptions
    )
  }

  /// Creates a Markdown parser configured for full-document syntax.
  public static func markdown(
    baseURL: URL? = nil,
    preprocessingOptions: AttributedStringMarkdownParser.PreprocessingOptions = .init()
  ) -> Self {
    .init(
      baseURL: baseURL,
      preprocessingOptions: preprocessingOptions
    )
  }
}
