#if canImport(UIKit) && canImport(SwiftUI)
import UIKit
import SwiftUI

/// Thin integration layer intended to be owned by Hamster's existing keyboard controller.
/// It deliberately does not import Hamster symbols, so it survives Hamster API changes.
@MainActor
public final class WTKeyboardOverlayBinding {
    public let runtime: WTKeyboardRuntime
    public let engine: WTIMEEngine
    private weak var inputController: UIInputViewController?
    private var hostingController: UIHostingController<WTPanelRootView>?
    private var cloudBinding: WTCloudCandidateBinding?
    private let compatibilityProfile: WTIMECompatibilityProfile?
    private let candidatePreferenceStore: WTCandidatePreferenceStore?

    public init(
        inputController: UIInputViewController,
        engine: WTIMEEngine,
        initialState: WTKeyboardState = .init(),
        cloudCandidateService: WTCloudCandidateService? = nil,
        compatibilityProfile: WTIMECompatibilityProfile? = nil,
        candidatePreferenceStore: WTCandidatePreferenceStore? = nil,
        onInputModeChanged: @escaping (WTInputMode) -> Void = { _ in }
    ) {
        self.inputController = inputController
        self.engine = engine
        self.compatibilityProfile = compatibilityProfile
        self.candidatePreferenceStore = candidatePreferenceStore
        self.runtime = WTKeyboardRuntime(state: initialState)

        runtime.insertText = { [weak inputController] text in
            inputController?.textDocumentProxy.insertText(text)
        }
        runtime.commitDirectText = { [weak inputController, weak engine] text in
            if engine?.context.isComposing == true {
                if let first = engine?.selectCandidate(at: 0), !first.isEmpty {
                    inputController?.textDocumentProxy.insertText(first)
                } else { engine?.reset() }
            }
            inputController?.textDocumentProxy.insertText(text)
        }
        runtime.deleteBackward = { [weak inputController, weak engine] in
            guard let engine else { inputController?.textDocumentProxy.deleteBackward(); return }
            if engine.context.isComposing {
                engine.deleteBackward()
                if let committed = engine.drainCommit(), !committed.isEmpty {
                    inputController?.textDocumentProxy.insertText(committed)
                }
            } else { inputController?.textDocumentProxy.deleteBackward() }
        }
        runtime.submitSpace = { [weak inputController, weak engine] in
            guard let engine else { inputController?.textDocumentProxy.insertText(" "); return }
            guard engine.context.isComposing else { inputController?.textDocumentProxy.insertText(" "); return }
            if engine.process(" ") {
                if let committed = engine.drainCommit(), !committed.isEmpty {
                    inputController?.textDocumentProxy.insertText(committed)
                }
            } else if let text = engine.selectCandidate(at: 0) {
                inputController?.textDocumentProxy.insertText(text)
            }
        }
        runtime.submitReturn = { [weak inputController, weak engine] in
            guard let engine else { inputController?.textDocumentProxy.insertText("\n"); return }
            if engine.context.isComposing, let text = engine.selectCandidate(at: 0) {
                inputController?.textDocumentProxy.insertText(text)
            } else {
                inputController?.textDocumentProxy.insertText("\n")
            }
        }
        runtime.advanceToNextInputMode = { [weak inputController] in
            inputController?.advanceToNextInputMode()
        }
        runtime.sendCharacterToRime = { [weak inputController, weak engine] text in
            guard let engine else { return }
            let handled = engine.process(text)
            if handled, let committed = engine.drainCommit(), !committed.isEmpty {
                inputController?.textDocumentProxy.insertText(committed)
            } else if !handled {
                inputController?.textDocumentProxy.insertText(text)
            }
        }
        runtime.selectCandidate = { [weak inputController, weak engine] index in
            if let text = engine?.selectCandidate(at: index) {
                inputController?.textDocumentProxy.insertText(text)
            }
        }
        runtime.moveCandidatePage = { [weak self, weak engine] direction in
            guard engine?.moveCandidatePage(direction) == true else { return }
            self?.refreshFromEngine()
        }
        runtime.refreshIMEContext = { [weak self] in self?.refreshFromEngine() }
        runtime.inputModeDidChange = { [weak engine] mode in
            engine?.setInputMode(mode)
            onInputModeChanged(mode)
        }
        if let cloudCandidateService {
            cloudBinding = WTCloudCandidateBinding(runtime: runtime, engine: engine, service: cloudCandidateService)
        }
        refreshFromEngine()
    }

    /// Install the SwiftUI overlay inside an existing UIInputViewController.
    public func install() {
        guard let controller = inputController else { return }
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()

        let host = UIHostingController(rootView: WTPanelRootView(runtime: runtime))
        host.view.backgroundColor = .clear
        controller.addChild(host)
        controller.view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: controller.view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor)
        ])
        host.didMove(toParent: controller)
        hostingController = host
    }

    public func refreshFromEngine() {
        refreshHostTraits()
        let context = engine.context
        runtime.composition = context.composition
        runtime.candidatePageState = context.candidatePage
        var displayed = context.candidates.enumerated().map { WTDisplayedCandidate(sourceIndex: $0.offset, candidate: $0.element) }
        if let compatibilityProfile {
            displayed = compatibilityProfile.apply(
                to: context.candidates,
                inputMode: compatibilityModeKey(runtime.state.inputMode),
                composition: context.composition
            )
        }
        if let candidatePreferenceStore {
            displayed = candidatePreferenceStore.applyIndexed(to: displayed)
        }
        runtime.candidates = displayed.map { $0.candidate.text }
        runtime.candidateSourceIndexes = displayed.map(\.sourceIndex)
        cloudBinding?.refresh(local: context, displayedLocal: displayed)
    }

    private func compatibilityModeKey(_ mode: WTInputMode) -> String {
        switch mode {
        case .chinesePinyin26: return "pinyin26"
        case .chinesePinyin9: return "pinyin9"
        case .doublePinyin: return "shuangpin"
        case .wubi: return "wubi86"
        case .stroke: return "stroke"
        case .english26: return "english26"
        case .handwriting: return "handwriting"
        }
    }

    /// Called when UIKit announces a host text-context transition. Active librime composition
    /// must not leak into the next field/app (a common custom-keyboard residual-text failure).
    public func prepareForHostContextChange() {
        if engine.context.isComposing { engine.reset() }
        runtime.composition = ""
        runtime.candidates = []
        runtime.candidateSourceIndexes = []
        runtime.candidatePageState = .singlePage
        runtime.candidateExpanded = false
        runtime.candidateActionTarget = nil
        runtime.longPressPopup = nil
    }

    public func prepareForMemoryPressure() {
        cloudBinding?.cancel()
        runtime.releaseTransientCaches()
    }

    public func refreshHostTraits() {
        guard let proxy = inputController?.textDocumentProxy else { return }
        runtime.returnKeyPresentation = WTReturnKeyPresentation(uiReturnKeyType: proxy.returnKeyType ?? .default)
    }
}

private extension WTReturnKeyPresentation {
    init(uiReturnKeyType: UIReturnKeyType) {
        let kind: WTReturnKeyKind
        switch uiReturnKeyType {
        case .default: kind = .default
        case .go: kind = .go
        case .google: kind = .google
        case .join: kind = .join
        case .next: kind = .next
        case .route: kind = .route
        case .search: kind = .search
        case .send: kind = .send
        case .yahoo: kind = .yahoo
        case .done: kind = .done
        case .emergencyCall: kind = .emergencyCall
        case .continue: kind = .continue
        @unknown default: kind = .default
        }
        self.init(kind: kind)
    }
}
#endif
