#if canImport(UIKit)
import UIKit
import Foundation

/// Device-local fallback for the correction surface. It does not imitate Tencent's
/// private model; it makes the UI operational before a richer provider is connected.
public final class WTLocalCorrectionService: WTCorrectionService {
    private let checker = UITextChecker()
    public init() {}

    public func suggestions(for text: String) async throws -> [WTCorrectionSuggestion] {
        guard !text.isEmpty else { return [] }
        let ns = text as NSString
        var result: [WTCorrectionSuggestion] = []
        var cursor = 0
        while cursor < ns.length {
            let range = NSRange(location: cursor, length: ns.length - cursor)
            let miss = checker.rangeOfMisspelledWord(in: text, range: range, startingAt: cursor, wrap: false, language: "en_US")
            if miss.location == NSNotFound { break }
            let word = ns.substring(with: miss)
            if let replacement = checker.guesses(forWordRange: miss, in: text, language: "en_US")?.first,
               let swiftRange = Range(miss, in: text) {
                result.append(.init(range: swiftRange, original: word, replacement: replacement))
            }
            cursor = miss.location + max(miss.length, 1)
        }
        return result
    }
}
#endif
