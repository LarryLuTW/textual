import SwiftUI

/// Properties that control how Textual renders custom emoji.
///
/// Use `EmojiProperties` to control the emoji’s size and baseline alignment relative to the
/// surrounding text.
///
/// Values are font-relative, so they scale with the current font size.
///
/// You can set these properties using the ``TextualNamespace/emojiProperties(_:)`` modifier.
public struct EmojiProperties: Sendable, Hashable {
  /// The emoji size, expressed as a font-relative value.
  public var size: FontScaled<CGSize>

  /// The emoji baseline offset, expressed as a font-relative value.
  public var baselineOffset: FontScaled<CGFloat>

  /// Creates emoji properties with a custom size and baseline offset.
  public init(
    size: FontScaled<CGSize>,
    baselineOffset: FontScaled<CGFloat>
  ) {
    self.size = size
    self.baselineOffset = baselineOffset
  }

  /// The default emoji properties.
  public static let `default` = EmojiProperties(
    size: .fontScaled(width: 1, height: 1),
    baselineOffset: .fontScaled(-0.1)
  )
}

extension EnvironmentValues {
  @Entry var emojiProperties: EmojiProperties = .default
}
