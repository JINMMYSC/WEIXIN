#if canImport(UIKit) && canImport(SwiftUI)
import Foundation

@MainActor
public final class WTCloudCandidateBinding {
    private weak var runtime: WTKeyboardRuntime?
    private weak var engine: WTIMEEngine?
    private let service: WTCloudCandidateService
    private var task: Task<Void, Never>?
    private var generation: UInt = 0

    public init(runtime: WTKeyboardRuntime, engine: WTIMEEngine, service: WTCloudCandidateService) {
        self.runtime = runtime
        self.engine = engine
        self.service = service
    }

    public func cancel() {
        task?.cancel()
        task = nil
        generation &+= 1
    }

    public func refresh(local context: WTIMEContext, displayedLocal: [WTDisplayedCandidate]? = nil) {
        task?.cancel()
        generation &+= 1
        let token = generation
        guard !context.composition.isEmpty, context.isComposing else { return }
        let composition = context.composition
        let local = context.candidates
        let display = displayedLocal
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let cloud = try await service.candidates(for: composition, limit: 8)
                guard !Task.isCancelled, token == generation, engine?.context.composition == composition else { return }
                apply(local: local, displayedLocal: display, cloud: cloud)
            } catch {
                // Network candidates are best-effort and must never break local typing.
            }
        }
    }

    private func apply(local: [WTCandidate], displayedLocal: [WTDisplayedCandidate]?, cloud: [WTCloudCandidate]) {
        guard let runtime else { return }
        var texts: [String] = []
        var indexes: [Int] = []
        var seen = Set<String>()
        let display = displayedLocal ?? local.enumerated().map { WTDisplayedCandidate(sourceIndex: $0.offset, candidate: $0.element) }

        if let first = display.first {
            texts.append(first.candidate.text); indexes.append(first.sourceIndex); seen.insert(first.candidate.text)
        }
        for item in cloud.sorted(by: { $0.score > $1.score }) where !seen.contains(item.text) {
            texts.append(item.text); indexes.append(-1); seen.insert(item.text)
        }
        for item in display.dropFirst() where !seen.contains(item.candidate.text) {
            texts.append(item.candidate.text); indexes.append(item.sourceIndex); seen.insert(item.candidate.text)
        }
        runtime.candidates = texts
        runtime.candidateSourceIndexes = indexes
    }
}
#endif
