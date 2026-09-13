import Foundation

/// A tiny protocol the open-source Hamster revision can conform its existing Rime
/// session/controller to. This removes the last UI dependency on concrete Hamster
/// symbols while still giving the overlay a real, typed session bridge.
public protocol WTHamsterRimeSessionProtocol: AnyObject {
    /// Current composition/preedit text shown above candidates.
    var wtComposition: String { get }
    /// Current visible Rime candidates in source order.
    var wtCandidates: [WTCandidate] { get }
    /// Whether Rime currently owns a composition.
    var wtIsComposing: Bool { get }
    /// Current Rime candidate page metadata. Public Hamster revisions that do not expose it can
    /// keep the default single-page implementation below.
    var wtCandidatePageState: WTCandidatePageState { get }

    /// Process one UTF-8 key/text input through Rime. Returns true when consumed.
    @discardableResult func wtProcess(_ input: String) -> Bool
    /// Drain librime get_commit() after a processed key/action.
    func wtDrainCommit() -> String?
    /// Switch schema/options/layout semantics for pinyin26/T9/shuangpin/Wubi/stroke/English.
    func wtSetInputMode(_ mode: WTInputMode)
    /// Optional lower-level mapping used when the selected Hamster revision exposes schema/options.
    /// Default implementation falls back to `wtSetInputMode` so existing conformances keep working.
    func wtApplyModeDescriptor(_ descriptor: WTRimeModeDescriptor, logicalMode: WTInputMode)
    /// Move the Rime candidate menu by one page without altering composition.
    @discardableResult func wtMoveCandidatePage(_ direction: WTCandidatePageDirection) -> Bool
    /// Select candidate at the original Rime candidate index and return committed text.
    func wtSelectCandidate(at index: Int) -> String?
    /// Delete inside Rime composition.
    func wtDeleteBackward()
    /// Clear current composition/session state without inserting text.
    func wtReset()
}


public extension WTHamsterRimeSessionProtocol {
    var wtCandidatePageState: WTCandidatePageState { .singlePage }
    func wtApplyModeDescriptor(_ descriptor: WTRimeModeDescriptor, logicalMode: WTInputMode) { wtSetInputMode(logicalMode) }
    @discardableResult func wtMoveCandidatePage(_ direction: WTCandidatePageDirection) -> Bool { false }
}

public final class WTHamsterRimeSessionAdapter: WTIMEEngine {
    private weak var session: WTHamsterRimeSessionProtocol?
    private let backendProfile: WTRimeBackendProfile

    public init(session: WTHamsterRimeSessionProtocol, backendProfile: WTRimeBackendProfile = .safeDefault) {
        self.session = session
        self.backendProfile = backendProfile
    }

    public var context: WTIMEContext {
        guard let session else { return .init(composition: "", candidates: [], isComposing: false) }
        return .init(
            composition: session.wtComposition,
            candidates: session.wtCandidates,
            isComposing: session.wtIsComposing,
            candidatePage: session.wtCandidatePageState
        )
    }

    @discardableResult public func process(_ input: String) -> Bool {
        session?.wtProcess(input) ?? false
    }

    public func drainCommit() -> String? { session?.wtDrainCommit() }
    public func setInputMode(_ mode: WTInputMode) {
        if let descriptor = backendProfile[mode] { session?.wtApplyModeDescriptor(descriptor, logicalMode: mode) }
        else { session?.wtSetInputMode(mode) }
    }
    @discardableResult public func moveCandidatePage(_ direction: WTCandidatePageDirection) -> Bool {
        session?.wtMoveCandidatePage(direction) ?? false
    }

    public func selectCandidate(at index: Int) -> String? {
        session?.wtSelectCandidate(at: index)
    }

    public func deleteBackward() { session?.wtDeleteBackward() }
    public func reset() { session?.wtReset() }
}
