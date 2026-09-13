#if canImport(UIKit) && canImport(SwiftUI)
import UIKit
import SwiftUI

/// Concrete keyboard-extension host for the overlay. A Hamster integration can either
/// subclass this and override `makeIMEEngine()`, or copy the three lifecycle lines into
/// its existing UIInputViewController.
open class WTKeyboardInputViewController: UIInputViewController {
    private var overlayBinding: WTKeyboardOverlayBinding?
    private var serviceBinder: WTKeyboardServiceBinder?

    /// Override in the Hamster target and return
    /// `WTHamsterRimeSessionAdapter(session: existingRimeSession)`.
    open func makeIMEEngine() -> WTIMEEngine? {
        #if DEBUG
        return WTPreviewIMEEngine()
        #else
        return nil
        #endif
    }

    open var appGroupIdentifier: String {
        Bundle.main.object(forInfoDictionaryKey: "WTAppGroupIdentifier") as? String
            ?? "group.7518554"
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        guard let engine = makeIMEEngine() else { return }
        let cloudService = WTKeyboardServiceBinder.cloudCandidateService(appGroupIdentifier: appGroupIdentifier)
        let binding = WTKeyboardOverlayBinding(inputController: self, engine: engine, cloudCandidateService: cloudService)
        let services = WTKeyboardServiceBinder(
            runtime: binding.runtime,
            appGroupIdentifier: appGroupIdentifier,
            openURL: { [weak self] url, completion in self?.extensionContext?.open(url, completionHandler: completion) }
        )
        services.bind()
        binding.refreshFromEngine()
        binding.install()
        serviceBinder = services
        overlayBinding = binding
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        serviceBinder?.reloadSharedSettings()
        serviceBinder?.consumeServiceResponses()
    }

    open override func didReceiveMemoryWarning() {
        serviceBinder?.persistSessionState()
        overlayBinding?.prepareForMemoryPressure()
        super.didReceiveMemoryWarning()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        // iOS may terminate a keyboard extension without first issuing a memory warning.
        // Persist only logical mode state whenever the keyboard leaves the screen.
        serviceBinder?.persistSessionState()
        super.viewDidDisappear(animated)
    }

    open override func textWillChange(_ textInput: UITextInput?) {
        super.textWillChange(textInput)
        overlayBinding?.prepareForHostContextChange()
    }

    open override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        overlayBinding?.refreshFromEngine()
        serviceBinder?.consumeServiceResponses()
    }
}
#endif
