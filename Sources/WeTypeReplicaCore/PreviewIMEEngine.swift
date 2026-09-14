import Foundation

/// Deterministic preview/test engine used by SwiftPM unit tests and UI previews only.
/// The Release keyboard target is wired to WTLibrimeRimeSession and never instantiates this type.
public final class WTPreviewIMEEngine: WTIMEEngine {
    private var buffer = ""

    public init() {}

    public var context: WTIMEContext {
        let candidates: [WTCandidate]
        switch buffer.lowercased() {
        case "ni": candidates = [.init(text: "你"), .init(text: "呢")]
        case "n": candidates = [.init(text: "你")]
        default: candidates = buffer.isEmpty ? [] : [.init(text: buffer)]
        }
        return .init(
            composition: buffer,
            compositionState: .init(
                length: buffer.count,
                cursorPosition: buffer.count,
                selectionStart: buffer.count,
                selectionEnd: buffer.count
            ),
            candidates: candidates,
            isComposing: !buffer.isEmpty,
            candidatePage: .singlePage
        )
    }

    @discardableResult
    public func process(_ input: String) -> Bool {
        guard !input.isEmpty, input.allSatisfy({ $0.isLetter }) else { return false }
        buffer.append(contentsOf: input.lowercased())
        return true
    }

    public func selectCandidate(at index: Int) -> String? {
        let candidates = context.candidates
        guard candidates.indices.contains(index) else { return nil }
        defer { buffer = "" }
        return candidates[index].text
    }

    public func deleteBackward() {
        guard !buffer.isEmpty else { return }
        buffer.removeLast()
    }

    public func reset() {
        buffer = ""
    }
}
