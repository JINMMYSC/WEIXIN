import Foundation

/// Create a WTClosureIMEEngine from the Rime session that Hamster already owns.
/// Concrete Hamster symbol names stay confined to these closures. V14 also accepts a declarative
/// backend profile so schema/option mappings can be changed without touching overlay UI code.
public enum WTHamsterAdapterTemplate {
    public static func make(
        backendProfile: WTRimeBackendProfile = .safeDefault,
        context: @escaping () -> WTIMEContext,
        process: @escaping (String) -> Bool,
        drainCommit: @escaping () -> String? = { nil },
        applyModeDescriptor: @escaping (WTRimeModeDescriptor, WTInputMode) -> Void = { _, _ in },
        fallbackSetInputMode: @escaping (WTInputMode) -> Void = { _ in },
        moveCandidatePage: @escaping (WTCandidatePageDirection) -> Bool = { _ in false },
        selectCandidate: @escaping (Int) -> String?,
        deleteBackward: @escaping () -> Void,
        reset: @escaping () -> Void
    ) -> WTIMEEngine {
        WTClosureIMEEngine(
            context: context,
            process: process,
            drainCommit: drainCommit,
            setInputMode: { mode in
                if let descriptor = backendProfile[mode] {
                    applyModeDescriptor(descriptor, mode)
                } else {
                    fallbackSetInputMode(mode)
                }
            },
            moveCandidatePage: moveCandidatePage,
            selectCandidate: selectCandidate,
            deleteBackward: deleteBackward,
            reset: reset
        )
    }
}
