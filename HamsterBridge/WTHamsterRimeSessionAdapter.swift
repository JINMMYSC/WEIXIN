import Foundation

/// A tiny protocol the open-source Hamster revision can conform its existing Rime
/// session/controller to. This removes the last UI dependency on concrete Hamster
/// symbols while still giving the overlay a real, typed session bridge.
public protocol WTHamsterRimeSessionProtocol: AnyObject {
    var wtComposition: String { get }
    var wtCompositionState: WTIMECompositionState { get }
    var wtCandidates: [WTCandidate] { get }
    var wtIsComposing: Bool { get }
    var wtCandidatePageState: WTCandidatePageState { get }

    @discardableResult func wtProcess(_ input: String) -> Bool
    func wtDrainCommit() -> String?
    func wtSetInputMode(_ mode: WTInputMode)
    func wtApplyModeDescriptor(_ descriptor: WTRimeModeDescriptor, logicalMode: WTInputMode)
    @discardableResult func wtMoveCandidatePage(_ direction: WTCandidatePageDirection) -> Bool
    func wtSelectCandidate(at index: Int) -> String?
    func wtDeleteBackward()
    func wtReset()

    func wtSetSimplifiedChinese(_ simplified: Bool)
    func wtSetFuzzyPinyin(_ option: WTFuzzyPinyinOption, enabled: Bool)
    func wtReloadPhase3Preferences()
    func wtSyncUserData()
}

public extension WTHamsterRimeSessionProtocol {
    var wtCompositionState: WTIMECompositionState {
        WTIMECompositionState(length: wtComposition.count, cursorPosition: wtComposition.count)
    }
    var wtCandidatePageState: WTCandidatePageState { .singlePage }
    func wtApplyModeDescriptor(_ descriptor: WTRimeModeDescriptor, logicalMode: WTInputMode) { wtSetInputMode(logicalMode) }
    @discardableResult func wtMoveCandidatePage(_ direction: WTCandidatePageDirection) -> Bool { false }
    func wtSetSimplifiedChinese(_ simplified: Bool) {}
    func wtSetFuzzyPinyin(_ option: WTFuzzyPinyinOption, enabled: Bool) {}
    func wtReloadPhase3Preferences() {}
    func wtSyncUserData() {}
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
            compositionState: session.wtCompositionState,
            candidates: session.wtCandidates,
            isComposing: session.wtIsComposing,
            candidatePage: session.wtCandidatePageState
        )
    }

    @discardableResult public func process(_ input: String) -> Bool { session?.wtProcess(input) ?? false }
    public func drainCommit() -> String? { session?.wtDrainCommit() }

    public func setInputMode(_ mode: WTInputMode) {
        if let descriptor = backendProfile[mode] { session?.wtApplyModeDescriptor(descriptor, logicalMode: mode) }
        else { session?.wtSetInputMode(mode) }
    }

    @discardableResult public func moveCandidatePage(_ direction: WTCandidatePageDirection) -> Bool {
        session?.wtMoveCandidatePage(direction) ?? false
    }

    public func selectCandidate(at index: Int) -> String? { session?.wtSelectCandidate(at: index) }
    public func deleteBackward() { session?.wtDeleteBackward() }
    public func reset() { session?.wtReset() }

    public func setSimplifiedChinese(_ simplified: Bool) { session?.wtSetSimplifiedChinese(simplified) }
    public func setFuzzyPinyin(_ option: WTFuzzyPinyinOption, enabled: Bool) {
        session?.wtSetFuzzyPinyin(option, enabled: enabled)
    }
    public func reloadPhase3Preferences() { session?.wtReloadPhase3Preferences() }
    public func syncUserData() { session?.wtSyncUserData() }
}
