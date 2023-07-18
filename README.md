# HyphenableText
HyphenableText is a `Text` view that displays one or multiple lines of text with support for hyphenation.

### The Problem
In SwiftUI, when passing a longer text to a `Text`, it will automatically wrap its content to go on multiple lines, but when a word on its own is longer than the available space, it will just be broken without any indication. What Apple does in the system apps is to add [hyphenation]([Title](https://en.wikipedia.org/wiki/Hyphen)).

This can be done in UIKit very easily by using a `AttributedString` and its `paragraphStyle` with a [`hyphenationFactor`](https://developer.apple.com/documentation/uikit/nsmutableparagraphstyle/1535553-hyphenationfactor) set to `1.0`. However, passing this `AttributedString` to a SwiftUI `Text` does nothing, as the component seems to be ignoring the paragraph style completely.

### The Solution
HyphenableText resorts to Core Foundation to produce a string that contains [soft hyphens](https://en.wikipedia.org/wiki/Soft_hyphen). 

A soft hypen (Unicode character `\u{00AD}`) lets the text presenter know that, in that location, there is an opportunity to break a word: when this happens, the presenter will also automatically display a hyphen.

In order to identify in which locations of the passed string there can be a hyphen, Core Foundation provides [`CFStringGetHyphenationLocationBeforeIndex`](https://developer.apple.com/documentation/corefoundation/1542693-cfstringgethyphenationlocationbe), which returns the next possible location for a hyphen, assuming that hyphenation is available for the current language (see [`CFStringIsHyphenationAvailableForLocale`](https://developer.apple.com/documentation/corefoundation/1543237-cfstringishyphenationavailablefo)).

You can invoke this algorithm directly by using the `softHyphenated(withLocale:hyphenCharacter:)` extension, which also provides valid default values for all parameters and can be invoked on any `String`.

## Installation
HyphenableText is available through [Swift Package Manager](https://swift.org/package-manager).

```swift
.package(url: "https://github.com/MrAsterisco/HyphenableText", from: "<see GitHub releases>")
```

### Latest Release
To find out the latest version, look at the Releases tab of this repository.

## Usage
HyphenableText can be used as any other SwiftUI view:

```swift
HyphenableText(
    text: "Antidisestablishmentarianism juxtaposed with ultramicroscopic-silicovolcanoconiosis presents an inextricable conundrum of lexical intricacy."
)
```

HyphenableText supports the same appearance modifiers that `Text` supports.

## Compatibility
HyphenableText requires **iOS 13.0 or later**, **macOS 10.15 or later**, **watchOS 6.0 or later**, **tvOS 13 or later**, or **Mac Catalyst 13 or later**.

## Contributions
All contributions to expand the library are welcome. Fork the repo, make the changes you want, and open a Pull Request.

If you make changes to the codebase, I am not enforcing a coding style, but I may ask you to make changes based on how the rest of the library is made.

## Status
This library is under **active development**. Even if most of the APIs are pretty straightforward, **they may change in the future**; but you don't have to worry about that, because releases will follow [Semantic Versioning 2.0.0](https://semver.org/).

## License
HyphenableText is distributed under the MIT license. [See LICENSE](https://github.com/MrAsterisco/HyphenableText/blob/master/LICENSE) for details.