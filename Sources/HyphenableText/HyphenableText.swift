//
//  HyphenableText.swift
//  
//
//  Created by Alessio Moiso on 18.07.23.
//

import SwiftUI
import Foundation

public extension String {
  /// The Unicode character of a soft hyphen.
  ///
  /// - see: [Wikipedia](https://en.wikipedia.org/wiki/Soft_hyphen).
  static let softHyphen = "\u{00AD}"
    
  /// Split the string using space as a separator and, for those substrings
  /// whose lengths are greater than or equal to minimumWordLength,
  /// replace them with a softHyphenated version..
  ///
  /// - note: This assumes that words are delineated by
  /// space characters, which may not be correct for all locales where
  /// CFStringIsHyphenationAvailableForLocale(_:) returns true. Consider
  /// using CFStringTokenizer to eliminate this assumption.
  func softHyphenateByWord(minimumWordLength: Int = 0, withLocale locale: Locale = .autoupdatingCurrent) -> Self {
      var substringArray: [String] = self.split(separator: " ", omittingEmptySubsequences: false).map({ String($0) })
        
      for (i, substring) in substringArray.enumerated() {
          if substring.count >= minimumWordLength {
              substringArray[i] = substring.softHyphenated(withLocale: locale)
          }
      }
        
      return substringArray.joined(separator: " ")
  }
  
  /// Insert a soft-hyphen character at every possible location in the string.
  ///
  /// - note: Soft-hyphens are only displayed when needed in order to allow
  /// words that are longer than the available space to flow on multiple lines.
  func softHyphenated(withLocale locale: Locale = .autoupdatingCurrent, hyphenCharacter: String = Self.softHyphen) -> Self {
    let localeRef = locale as CFLocale
    guard CFStringIsHyphenationAvailableForLocale(localeRef) else {
      return self
    }
    
    let mutableSelf = NSMutableString(string: self)
    var hyphenationLocations = Array<Bool>(repeating: false, count: count)
    let range = CFRangeMake(0, count)
    
    for i in 0..<count {
      let nextLocation = CFStringGetHyphenationLocationBeforeIndex(
        mutableSelf as CFString,
        i,
        range,
        .zero,
        localeRef,
        nil
      )
      
      if nextLocation >= 0 && nextLocation < count {
        hyphenationLocations[nextLocation] = true
      }
    }
    
    for i in (0..<count).reversed() {
      guard hyphenationLocations[i] else { continue }
      mutableSelf.insert(hyphenCharacter, at: i)
    }
    
    return mutableSelf as String
  }
}

/// A view that displays one or more lines of text with hyphenation.
///
/// The view supports the same modifiers as the `Text` view, such as
/// `font`, `bold`, `foregroundColor`, and more.
///
/// You can invoke the `softHyphenated` extension on any `String` to
/// get the same result as the text that is represented in this view.
///
/// The hyphenation is performed using the `locale` that is available in the Environment.
public struct HyphenableText: View {
  @Environment(\.locale) private var locale
  
  public let text: String
  public let minimumWordLength: Int
  
  public init(_ text: String, ignoreWordsShorterThan minimumWordLength: Int = 0) {
    self.text = text
    self.minimumWordLength = minimumWordLength
  }
  
  public var body: some View {
    Text(
      text
        .softHyphenateByWord(
          minimumWordLength: minimumWordLength,
          withLocale: locale
        )
    )
  }
}

// MARK: - Preview
struct HyphenableText_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 8) {
      HyphenableText(
        "Antidisestablishmentarianism juxtaposed with ultramicroscopic-silicovolcanoconiosis presents an inextricable conundrum of lexical intricacy."
      )
      .font(.largeTitle)
      .foregroundColor(.red)
      .frame(maxWidth: .infinity, alignment: .leading)
      
      HyphenableText(
        "Cryptococcus neoformans serotype B manifesting pneumonoultramicroscopicsilicovolcanoconiosis perplexes pulmonologists worldwide."
      )
      .font(.body)
      .frame(maxWidth: .infinity, alignment: .leading)
      
      HyphenableText(
        "Supercalifragilisticexpialidocious intergalactic hypernova cataclysmic cosmogenesis defies conventional astrophysical comprehension."
      )
      .font(.caption)
      .foregroundColor(.secondary)
      .frame(maxWidth: .infinity, alignment: .leading)
      
      Spacer()
    }
    .padding()
  }
}
