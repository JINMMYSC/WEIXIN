#if canImport(ActivityKit)
import ActivityKit
import Foundation

@available(iOS 16.1, *)
@MainActor
public final class WTVoiceLiveActivityController {
    private var activity: Activity<WTVoiceActivityAttributes>?
    private var lastPublishedState: WTVoiceActivityAttributes.ContentState?
    public init() {}

    public func start(requestID: UUID) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        // A voice request is singular: retire a stale previous activity before creating the next.
        if let existing = activity {
            Task { await self.endActivity(existing, state: .init(phase: "ended", isFinal: true), immediate: true) }
        }
        let attributes = WTVoiceActivityAttributes(requestID: requestID.uuidString)
        let state = WTVoiceActivityAttributes.ContentState(phase: "preparing")
        do {
            if #available(iOS 16.2, *) {
                activity = try Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil), pushType: nil)
            } else {
                activity = try Activity.request(attributes: attributes, contentState: state, pushType: nil)
            }
            lastPublishedState = state
        } catch {
            activity = nil
            lastPublishedState = nil
        }
    }

    public func update(_ state: WTVoiceState) {
        guard let activity else { return }
        let contentState: WTVoiceActivityAttributes.ContentState
        switch state {
        case .idle: contentState = .init(phase: "idle")
        case .preparing: contentState = .init(phase: "preparing")
        case .recording(let partial): contentState = .init(phase: "recording", partialText: partial)
        case .recognizing: contentState = .init(phase: "recognizing")
        case .result(let text): contentState = .init(phase: "result", partialText: text, isFinal: true)
        case .failed(let error): contentState = .init(phase: "failed", partialText: error, isFinal: true)
        }

        // ActivityKit updates are system-budgeted. Suppress identical state/text churn from speech
        // partial callbacks while still publishing genuine transcript or phase changes.
        if let last = lastPublishedState,
           last.phase == contentState.phase,
           last.partialText == contentState.partialText,
           last.isFinal == contentState.isFinal { return }
        lastPublishedState = contentState

        Task {
            if #available(iOS 16.2, *) {
                await activity.update(.init(state: contentState, staleDate: contentState.isFinal ? Date().addingTimeInterval(15) : nil))
            } else {
                await activity.update(using: contentState)
            }
        }
    }

    public func end(finalText: String? = nil) {
        guard let activity else { return }
        let finalState = WTVoiceActivityAttributes.ContentState(
            phase: "ended",
            partialText: finalText ?? lastPublishedState?.partialText ?? "",
            isFinal: true
        )
        self.activity = nil
        lastPublishedState = nil
        Task { await endActivity(activity, state: finalState, immediate: false) }
    }

    private func endActivity(
        _ activity: Activity<WTVoiceActivityAttributes>,
        state: WTVoiceActivityAttributes.ContentState,
        immediate: Bool
    ) async {
        if #available(iOS 16.2, *) {
            let policy: ActivityUIDismissalPolicy = immediate ? .immediate : .after(Date().addingTimeInterval(2.0))
            await activity.end(.init(state: state, staleDate: nil), dismissalPolicy: policy)
        } else {
            await activity.end(using: state, dismissalPolicy: immediate ? .immediate : .default)
        }
    }
}
#endif
