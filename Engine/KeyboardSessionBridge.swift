import Foundation

struct KeyboardOutput: Equatable {
    let snapshot: InputSnapshot
    let committedText: String?
}

final class KeyboardSessionBridge {
    private let session: InputSession
    private let engine: PinyinEngine
    private let learning: CandidateLearningStore
    private let candidateStore = CandidateStore()
    private var nextRequestID = 0
    private var version = 0

    init(
        session: InputSession = InputSession(),
        engine: PinyinEngine = EmptyPinyinEngine(),
        learning: CandidateLearningStore = InMemoryCandidateLearningStore()
    ) {
        self.session = session
        self.engine = engine
        self.learning = learning
    }

    @discardableResult
    func handle(_ event: InputEvent) -> KeyboardOutput {
        let pending = event == .commitPending ? session.snapshot.composingText : nil
        _ = session.process(event)
        switch event {
        case .insert, .deleteBackward:
            refreshCandidates(for: session.snapshot.composingText)
        case .commitPending, .reset:
            candidateStore.reset()
        }
        return KeyboardOutput(snapshot: session.snapshot, committedText: pending?.isEmpty == false ? pending : nil)
    }

    @discardableResult
    func selectCandidate(_ candidate: InputCandidate) -> KeyboardOutput {
        learning.recordSelection(candidate)
        let snapshot = session.commitCandidate(candidate.text)
        candidateStore.reset()
        return KeyboardOutput(snapshot: snapshot, committedText: candidate.text)
    }

    func commitFirstCandidate() -> KeyboardOutput? {
        guard let candidate = session.snapshot.candidates.first else { return nil }
        return selectCandidate(candidate)
    }

    /// Applies an asynchronous engine result only when it is newer than the
    /// result already shown for this session.
    @discardableResult
    func applyCandidateUpdate(_ update: CandidateUpdate) -> Bool {
        guard candidateStore.apply(update) else { return false }
        version = max(version, update.version)
        nextRequestID = max(nextRequestID, update.requestID)
        _ = session.replaceCandidates(update.candidates)
        return true
    }

    private func refreshCandidates(for composingText: String) {
        version += 1
        nextRequestID += 1
        let update = CandidateUpdate(
            version: version,
            requestID: nextRequestID,
            candidates: engine.candidates(for: composingText)
        )
        _ = applyCandidateUpdate(update)
    }
}
