import UIKit
import SwiftUI

final class HamsterKeyboardInputViewController: UIInputViewController {
    private let phase3Session = WTPhase3AdapterSmokeSession()
    private lazy var engine: WTIMEEngine = WTHamsterRimeSessionAdapter(session: phase3Session)
    private var runtime: WTKeyboardRuntime?
    private var hostingController: UIHostingController<WTPhase2KeyboardRootView>?
    private var heightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        #if DEBUG
        assert(WTPhase3AdapterSmokeSession.selfTest(), "Phase 3 adapter/T9 smoke test failed")
        #endif

        let initialMode: WTInputMode = .chinesePinyin9
        phase3Session.wtSetInputMode(initialMode)
        let runtime = WTKeyboardRuntime(state: WTKeyboardState(inputMode: initialMode))
        runtime.toolbarEnabled = false
        wireRuntime(runtime)
        self.runtime = runtime
        refreshFromEngine()
        installPhase2Root(runtime: runtime)
        installKeyboardHeightConstraint()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshFromEngine()
    }

    override func textWillChange(_ textInput: UITextInput?) {
        super.textWillChange(textInput)
        engine.reset()
        runtime?.composition = ""
        runtime?.candidates = []
        runtime?.candidateSourceIndexes = []
        runtime?.candidatePageState = .singlePage
        runtime?.candidateExpanded = false
        runtime?.candidateActionTarget = nil
        runtime?.longPressPopup = nil
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        refreshFromEngine()
    }

    override func didReceiveMemoryWarning() {
        runtime?.releaseTransientCaches()
        super.didReceiveMemoryWarning()
    }

    private func installKeyboardHeightConstraint() {
        let constraint = view.heightAnchor.constraint(equalToConstant: 268)
        constraint.priority = UILayoutPriority(999)
        constraint.isActive = true
        heightConstraint = constraint
    }

    private func installPhase2Root(runtime: WTKeyboardRuntime) {
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()

        let host = UIHostingController(rootView: WTPhase2KeyboardRootView(runtime: runtime))
        host.view.backgroundColor = .clear
        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        host.didMove(toParent: self)
        hostingController = host
    }

    private func wireRuntime(_ runtime: WTKeyboardRuntime) {
        runtime.insertText = { [weak self] text in
            self?.textDocumentProxy.insertText(text)
        }

        runtime.commitDirectText = { [weak self] text in
            guard let self else { return }
            if self.engine.context.isComposing {
                if let first = self.engine.selectCandidate(at: 0), !first.isEmpty {
                    self.textDocumentProxy.insertText(first)
                } else {
                    self.engine.reset()
                }
            }
            self.textDocumentProxy.insertText(text)
            self.refreshFromEngine()
        }

        runtime.deleteBackward = { [weak self] in
            guard let self else { return }
            if self.engine.context.isComposing {
                self.engine.deleteBackward()
                if let committed = self.engine.drainCommit(), !committed.isEmpty {
                    self.textDocumentProxy.insertText(committed)
                }
            } else {
                self.textDocumentProxy.deleteBackward()
            }
            self.refreshFromEngine()
        }

        runtime.submitSpace = { [weak self] in
            guard let self else { return }
            if self.engine.context.isComposing {
                if self.engine.process(" ") {
                    if let committed = self.engine.drainCommit(), !committed.isEmpty {
                        self.textDocumentProxy.insertText(committed)
                    }
                } else if let first = self.engine.selectCandidate(at: 0) {
                    self.textDocumentProxy.insertText(first)
                }
            } else {
                self.textDocumentProxy.insertText(" ")
            }
            self.refreshFromEngine()
        }

        runtime.submitReturn = { [weak self] in
            guard let self else { return }
            if self.engine.context.isComposing, let first = self.engine.selectCandidate(at: 0) {
                self.textDocumentProxy.insertText(first)
            } else {
                self.textDocumentProxy.insertText("\n")
            }
            self.refreshFromEngine()
        }

        runtime.advanceToNextInputMode = { [weak self] in
            self?.advanceToNextInputMode()
        }

        runtime.sendCharacterToRime = { [weak self] text in
            guard let self else { return }
            let handled = self.engine.process(text)
            if handled {
                if let committed = self.engine.drainCommit(), !committed.isEmpty {
                    self.textDocumentProxy.insertText(committed)
                }
            } else {
                self.textDocumentProxy.insertText(text)
            }
            self.refreshFromEngine()
        }

        runtime.selectCandidate = { [weak self] index in
            guard let self else { return }
            if let text = self.engine.selectCandidate(at: index) {
                self.textDocumentProxy.insertText(text)
            }
            self.refreshFromEngine()
        }

        runtime.moveCandidatePage = { [weak self] direction in
            guard let self else { return }
            _ = self.engine.moveCandidatePage(direction)
            self.refreshFromEngine()
        }

        runtime.refreshIMEContext = { [weak self] in
            self?.refreshFromEngine()
        }

        runtime.inputModeDidChange = { [weak self] mode in
            self?.engine.setInputMode(mode)
            self?.refreshFromEngine()
        }
    }

    private func refreshFromEngine() {
        guard let runtime else { return }
        let context = engine.context
        runtime.composition = context.composition
        runtime.candidates = context.candidates.map(\.text)
        runtime.candidateSourceIndexes = Array(context.candidates.indices)
        runtime.candidatePageState = context.candidatePage
        runtime.returnKeyPresentation = WTReturnKeyPresentation(kind: returnKeyKind(textDocumentProxy.returnKeyType ?? .default))
    }

    private func returnKeyKind(_ type: UIReturnKeyType) -> WTReturnKeyKind {
        switch type {
        case .default: return .default
        case .go: return .go
        case .google: return .google
        case .join: return .join
        case .next: return .next
        case .route: return .route
        case .search: return .search
        case .send: return .send
        case .yahoo: return .yahoo
        case .done: return .done
        case .emergencyCall: return .emergencyCall
        case .continue: return .continue
        @unknown default: return .default
        }
    }
}
