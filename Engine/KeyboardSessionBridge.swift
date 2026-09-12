import Foundation

struct KeyboardOutput: Equatable {
    let snapshot: InputSnapshot
    let committedText: String?
}

final class KeyboardSessionBridge {
    private let session: InputSession
    private let engine: PinyinEngine
    private let candidateStore = CandidateStore()
    private var nextRequestID = 0
    private var version = 0

    init(session: InputSession = InputSession(), engine: PinyinEngine = EmptyPinyinEngine()) {
        self.session = session
        self.engine = engine
    }

    @discardableResult
    func handle(_ event: InputEvent) -> KeyboardOutput {
        let pending = event == .commitPending ? session.snapshot.composingText : nil
        _ = session.process(event)
        switch event {
        case .insert, .deleteBackward:
            refreshCandidates(for: snapshot.composingText)
        case .commitPending, .reset:
            candidateStore.reset()
        }
        return KeyboardOutput(snapshot: session.snapshot, committedText: pending?.isEmpty == false ? pending : nil)
    }

    @discardableResult
    func selectCandidate(_ candidate: InputCandidate) -> KeyboardOutput {
        let snapshot = session.commitCandidate(candidate.text)
        candidateStore.reset()
        return KeyboardOutput(snapshot: snapshot, committedText: candidate.text)
    }

    private func refreshCandidates(for composingText: String) {
        version += 1
        nextRequestID += 1
        let update = CandidateUpdate(
            version: version,
            requestID: nextRequestID,
            candidates: engine.candidates(for: composingText)
        )
        guard candidateStore.apply(update) else { return }
        session.replaceCandidates(update.candidates)
    }
}
