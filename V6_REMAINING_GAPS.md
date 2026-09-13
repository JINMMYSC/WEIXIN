# V6 Remaining hard gaps

1. **Mac/Xcode first build** — use `XcodeIntegration/project.yml`, fix any real iOS SDK/API availability errors, set signing team and App Group.
2. **Concrete Hamster conformance** — in the exact Hamster source revision, map its current Rime context/candidate/process APIs to `WTHamsterRimeSessionProtocol`.
3. **On-device visual calibration** — capture WeType 3.5.3 and replica on the same iPhone model; feed measured values into `WTVisualCalibrationProfile`/theme/layout tokens.
4. **Provider productionization** — speech bridge, translation, AI/rewrite, cloud candidate, hot-word feed, sticker/GIF content, richer handwriting recognizer.
5. **Host-specific WeChat handoff** — `WTBookVideoPanelView` UI is present; actual open/send into WeChat requires an app-owned, legally available host handoff implementation.
6. **Clean-room icon pass** — replace SF Symbol placeholders with independently redrawn icons based on measured geometry/style, not copied Tencent assets.
7. **Regression matrix** — Notes, Messages/WeChat-like text fields, Spotlight, secure text fields, landscape, dark mode, low-memory extension restart, English→number→return, candidate commit residual-text regression.
