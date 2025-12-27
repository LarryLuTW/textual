import Foundation

/// A custom emoji definition used during Markdown preprocessing.
///
/// You can pass a set of `Emoji` values in
/// ``AttributedStringMarkdownParser/PreprocessingOptions`` to expand
/// `:shortcode:` sequences into inline attachments.
public struct Emoji: Hashable, Sendable, Codable {
  /// The shortcode used in the markup, without surrounding `:` characters.
  public let shortcode: String

  /// The URL to load the emoji image from.
  public let url: URL

  /// Creates a custom emoji definition.
  public init(shortcode: String, url: URL) {
    self.shortcode = shortcode
    self.url = url
  }
}
