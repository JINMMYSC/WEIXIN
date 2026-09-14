import Foundation

/// Real Phase 3 librime session used by Release builds.
///
/// The C/Objective-C bridge is deliberately tiny and pinned to the public LibrimeKit/librime
/// binary revision prepared by `ci_prepare_librimekit.sh`. The keyboard UI only sees the
/// WTHamsterRimeSessionProtocol boundary.
final class WTLibrimeRimeSession: WTHamsterRimeSessionProtocol {
    private static let appGroupID = "group.7518554"

    private let bridge: WTLibrimeBridge
    private var logicalMode: WTInputMode = .chinesePinyin9
    private var snapshotStorage: WTLibrimeContextSnapshot

    init() {
        let fileManager = FileManager.default
        let bundle = Bundle.main
        let sharedURL = bundle.url(forResource: "RimeSharedSupport", withExtension: nil)
        let userRoot = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupID)
            ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let userURL = userRoot.appendingPathComponent("RimeUserData", isDirectory: true)
        try? fileManager.createDirectory(at: userURL, withIntermediateDirectories: true)

        let sharedPath = sharedURL?.path ?? bundle.bundlePath
        bridge = WTLibrimeBridge(sharedDataDir: sharedPath, userDataDir: userURL.path)
        snapshotStorage = bridge.snapshot()
    }

    var wtComposition: String { snapshotStorage.composition }
    var wtCandidates: [WTCandidate] {
        snapshotStorage.candidates.map { record in
            WTCandidate(text: record.text, comment: record.comment.isEmpty ? nil : record.comment)
        }
    }
    var wtIsComposing: Bool { snapshotStorage.composing }
    var wtCandidatePageState: WTCandidatePageState {
        WTCandidatePageState(
            currentPage: snapshotStorage.pageNumber,
            pageSize: snapshotStorage.pageSize,
            hasPrevious: snapshotStorage.pageNumber > 0,
            hasNext: !snapshotStorage.lastPage
        )
    }

    @discardableResult
    func wtProcess(_ input: String) -> Bool {
        let normalized = normalizedInput(input)
        let consumed = bridge.processText(normalized)
        refresh()
        return consumed
    }

    func wtDrainCommit() -> String? {
        let committed = bridge.drainCommit()
        refresh()
        return committed
    }

    func wtSetInputMode(_ mode: WTInputMode) {
        logicalMode = mode
        bridge.reset()
        refresh()
    }

    func wtApplyModeDescriptor(_ descriptor: WTRimeModeDescriptor, logicalMode mode: WTInputMode) {
        logicalMode = mode
        bridge.reset()
        if let schemaID = descriptor.schemaID, !schemaID.isEmpty {
            _ = bridge.selectSchema(schemaID)
        }
        for (option, value) in descriptor.options {
            bridge.setOption(option, value: value)
        }
        for (property, value) in descriptor.properties {
            bridge.setProperty(property, value: value)
        }
        refresh()
    }

    @discardableResult
    func wtMoveCandidatePage(_ direction: WTCandidatePageDirection) -> Bool {
        let moved = bridge.movePage(direction == .previous ? -1 : 1)
        refresh()
        return moved
    }

    func wtSelectCandidate(at index: Int) -> String? {
        let committed = bridge.selectCandidate(at: index)
        refresh()
        return committed
    }

    func wtDeleteBackward() {
        bridge.deleteBackward()
        refresh()
    }

    func wtReset() {
        bridge.reset()
        refresh()
    }

    private func refresh() {
        snapshotStorage = bridge.snapshot()
    }

    private func normalizedInput(_ input: String) -> String {
        guard logicalMode == .chinesePinyin9 else { return input.lowercased() }
        if let digit = Self.t9GroupToDigit[input.uppercased()] { return digit }
        return input
    }

    private static let t9GroupToDigit: [String: String] = [
        "ABC": "2",
        "DEF": "3",
        "GHI": "4",
        "JKL": "5",
        "MNO": "6",
        "PQRS": "7",
        "TUV": "8",
        "WXYZ": "9"
    ]
}
