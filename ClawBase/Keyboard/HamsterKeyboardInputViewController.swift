import UIKit
import SwiftUI

final class HamsterKeyboardInputViewController: UIInputViewController {
    private static let appGroupID = "group.7518554"
    private static let recentEmojiKey = "phase3.recentEmoji"

    private lazy var phase3Session: WTHamsterRimeSessionProtocol = {
        #if DEBUG
        return WTPhase3AdapterSmokeSession()
        #else
        return WTLibrimeRimeSession()
        #endif
    }()
    private lazy var engine: WTIMEEngine = WTHamsterRimeSessionAdapter(
        session: phase3Session,
        backendProfile: .phase3PublicLibrime
    )
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
        engine.setInputMode(initialMode)
        let recents = UserDefaults(suiteName: Self.appGroupID)?.stringArray(forKey: Self.recentEmojiKey) ?? []
        let runtime = WTKeyboardRuntime(
            state: WTKeyboardState(inputMode: initialMode),
            recentEmoji: Array(recents.prefix(48))
        )
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
        // The extracted WeType 3.5.3 canvas is exactly 414x224.  During composition the
        // candidate area is 18pt preedit + 40pt candidates, so 282pt avoids the previous
        // vertical squeeze that distorted all key rectangles while typing.
        let measuredHeight = WTTheme353.keyboardHeight + WTTheme353.compositionHeight + WTTheme353.candidateCompactHeight
        let constraint = view.heightAnchor.constraint(equalToConstant: CGFloat(measuredHeight))
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

        runtime.recordEmoji = { symbol in
            let defaults = UserDefaults(suiteName: Self.appGroupID)
            var items = defaults?.stringArray(forKey: Self.recentEmojiKey) ?? []
            items.removeAll { $0 == symbol }
            items.insert(symbol, at: 0)
            if items.count > 48 { items.removeLast(items.count - 48) }
            defaults?.set(items, forKey: Self.recentEmojiKey)
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
