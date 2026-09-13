#if canImport(UIKit) && canImport(SwiftUI) && canImport(Network)
import UIKit
import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class WTQuickSendShareModel: ObservableObject {
    @Published var items: [WTQuickSendShareView.Item] = []
    @Published var peers: [WTPeerDevice] = []
    @Published var isLoading = true
    @Published var isSending = false
    @Published var statusText = "正在读取分享内容…"
    @Published var errorText: String?
    @Published var overallProgress: Double = 0
    @Published var canRetry = false

    var files: [URL] = []
    private var batch: WTTransferBatch?
    private var lastPeer: WTPeerDevice?
    private let maxTransferAttempts = 3
    private(set) var transfer: WTBonjourTransferService

    init(pairingCode: String?) {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("WTIncoming", isDirectory: true)
        transfer = .init(deviceName: UIDevice.current.name, receiveDirectory: dir, pairingCode: pairingCode)
        transfer.onPeersChange = { [weak self] peers in DispatchQueue.main.async { self?.peers = peers } }
        transfer.onStateChange = { [weak self] state in
            DispatchQueue.main.async { self?.apply(state) }
        }
    }

    func begin() { transfer.startDiscovery() }
    func stop() { transfer.stopDiscovery(); transfer.stopHosting() }

    func setLoadedFiles(_ urls: [URL]) {
        files = urls
        batch = WTTransferBatch(names: urls.map(\.lastPathComponent))
        canRetry = false
        items = urls.map { url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return .init(name: url.lastPathComponent, detail: Self.byteCount(size))
        }
        isLoading = false
        statusText = urls.isEmpty ? "没有可发送的内容" : "选择附近设备发送"
    }

    func failLoading(_ message: String) {
        isLoading = false
        errorText = message
        statusText = "读取失败"
    }

    func send(to peer: WTPeerDevice) async throws {
        guard !files.isEmpty else { throw WTShareError.noItems }
        lastPeer = peer
        if batch == nil || batch?.cancelled == true { batch = WTTransferBatch(names: files.map(\.lastPathComponent)) }
        batch?.retryFailed(maxAttempts: maxTransferAttempts)
        isSending = true
        canRetry = false
        errorText = nil
        defer { isSending = false }

        while let index = batch?.beginNext() {
            try Task.checkCancellation()
            let url = files[index]
            statusText = files.count == 1 ? "正在发送 \(url.lastPathComponent)" : "正在发送 \(index + 1)/\(files.count)"
            do {
                try await transfer.send(file: url, to: peer)
                batch?.markCompleted(index)
                overallProgress = batch?.overallProgress ?? 0
            } catch is CancellationError {
                batch?.cancel()
                statusText = "已取消发送"
                overallProgress = batch?.overallProgress ?? 0
                throw CancellationError()
            } catch {
                batch?.markFailed(index, message: error.localizedDescription)
                overallProgress = batch?.overallProgress ?? 0
                canRetry = batch?.hasRetryableFailure(maxAttempts: maxTransferAttempts) ?? false
                statusText = canRetry ? "发送失败，可重试" : "发送失败，已达重试上限"
                throw error
            }
        }
        statusText = "发送完成"
        overallProgress = 1
        canRetry = false
    }

    func retryLastPeer() async throws {
        guard let lastPeer else { throw WTShareError.noItems }
        try await send(to: lastPeer)
    }

    func cancelSending() {
        batch?.cancel()
        isSending = false
        canRetry = false
        statusText = "已取消发送"
    }

    private func apply(_ state: WTTransferState) {
        switch state {
        case .idle: break
        case .discovering:
            if !isLoading && !isSending { statusText = "正在查找附近设备…" }
        case .connecting(let peer): statusText = "正在连接 \(peer)…"
        case .transferring(let peer, let progress):
            statusText = "正在发送到 \(peer)"
            // Per-file progress is still useful even when multiple files are queued.
            overallProgress = max(0, min(1, progress))
        case .completed(let peer): statusText = "已发送到 \(peer)"
        case .failed(let message):
            errorText = message
            statusText = "发送失败"
        }
    }

    private static func byteCount(_ bytes: Int) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(max(0, bytes)), countStyle: .file)
    }
}

public final class WTQuickSendShareViewController: UIViewController {
    private lazy var model = WTQuickSendShareModel(pairingCode: sharedPairingCode())
    private var host: UIHostingController<AnyView>?
    private var stagedFiles: [URL] = []
    private var sendTask: Task<Void, Never>?

    public override func viewDidLoad() {
        super.viewDidLoad()
        mount()
        model.begin()
        Task { await loadItems() }
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        model.stop()
    }

    deinit {
        for url in stagedFiles { try? FileManager.default.removeItem(at: url) }
    }

    private func mount() {
        let view = WTQuickSendShareContainer(
            model: model,
            onCancel: { [weak self] in
                guard let self else { return }
                self.sendTask?.cancel()
                self.model.cancelSending()
                self.extensionContext?.cancelRequest(withError: NSError(domain: "WTShare", code: 1, userInfo: [NSLocalizedDescriptionKey: "用户取消"]))
            },
            onSend: { [weak self] peer in
                guard let self else { return }
                self.startSend { [weak self] in
                    guard let self else { return }
                    try await self.model.send(to: peer)
                }
            },
            onRetry: { [weak self] in
                guard let self else { return }
                self.startSend { [weak self] in
                    guard let self else { return }
                    try await self.model.retryLastPeer()
                }
            }
        )
        let host = UIHostingController(rootView: AnyView(view))
        addChild(host)
        self.view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        host.didMove(toParent: self)
        self.host = host
    }

    private func startSend(_ operation: @escaping @MainActor () async throws -> Void) {
        sendTask?.cancel()
        sendTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await operation()
                guard !Task.isCancelled else { return }
                self.extensionContext?.completeRequest(returningItems: nil)
            } catch is CancellationError {
                self.model.statusText = "已取消发送"
            } catch {
                self.model.errorText = error.localizedDescription
                self.model.statusText = "发送失败，可重试"
                self.model.canRetry = true
            }
        }
    }

    private func loadItems() async {
        var urls: [URL] = []
        var failures = 0
        for input in extensionContext?.inputItems as? [NSExtensionItem] ?? [] {
            for provider in input.attachments ?? [] {
                do {
                    if let url = try await stage(provider: provider) {
                        urls.append(url)
                    }
                } catch {
                    failures += 1
                }
            }
        }
        stagedFiles = urls
        if urls.isEmpty && failures > 0 {
            model.failLoading("无法读取分享内容")
        } else {
            model.setLoadedFiles(urls)
            if failures > 0 { model.errorText = "有 \(failures) 项内容无法读取，已跳过" }
        }
    }

    /// Copies provider content into the extension's own temporary directory before returning.
    /// Provider file URLs can become invalid as soon as the load callback returns, so keeping the
    /// original URL is unsafe and caused intermittent failures in earlier builds.
    private func stage(provider: NSItemProvider) async throws -> URL? {
        let preferred = [
            UTType.fileURL.identifier,
            UTType.image.identifier,
            UTType.movie.identifier,
            UTType.audio.identifier,
            UTType.data.identifier,
            UTType.url.identifier,
            UTType.plainText.identifier
        ]
        let identifier = preferred.first(where: { provider.hasItemConformingToTypeIdentifier($0) })
            ?? provider.registeredTypeIdentifiers.first
        guard let identifier else { return nil }

        if identifier != UTType.plainText.identifier && identifier != UTType.url.identifier {
            if let url = try? await copyFileRepresentation(provider, typeIdentifier: identifier) { return url }
            if let url = try? await copyDataRepresentation(provider, typeIdentifier: identifier) { return url }
        }

        if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier),
           let sharedURL = try? await loadURL(provider) {
            return try stageText(sharedURL.absoluteString, suggestedName: "shared-link.txt")
        }
        if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier),
           let text = try? await loadText(provider) {
            return try stageText(text, suggestedName: "shared-text.txt")
        }
        return nil
    }

    private func copyFileRepresentation(_ provider: NSItemProvider, typeIdentifier: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { [weak self] source, error in
                if let error { continuation.resume(throwing: error); return }
                guard let self, let source else { continuation.resume(throwing: WTShareError.unreadableItem); return }
                do {
                    let destination = self.uniqueStagingURL(suggestedName: provider.suggestedName ?? source.lastPathComponent)
                    try FileManager.default.copyItem(at: source, to: destination)
                    continuation.resume(returning: destination)
                } catch { continuation.resume(throwing: error) }
            }
        }
    }

    private func copyDataRepresentation(_ provider: NSItemProvider, typeIdentifier: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadDataRepresentation(forTypeIdentifier: typeIdentifier) { [weak self] data, error in
                if let error { continuation.resume(throwing: error); return }
                guard let self, let data else { continuation.resume(throwing: WTShareError.unreadableItem); return }
                do {
                    let ext = UTType(typeIdentifier)?.preferredFilenameExtension
                    let base = provider.suggestedName ?? "shared-\(UUID().uuidString)"
                    let name = (ext == nil || (base as NSString).pathExtension == ext) ? base : "\(base).\(ext!)"
                    let destination = self.uniqueStagingURL(suggestedName: name)
                    try data.write(to: destination, options: .atomic)
                    continuation.resume(returning: destination)
                } catch { continuation.resume(throwing: error) }
            }
        }
    }

    private func loadURL(_ provider: NSItemProvider) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadObject(ofClass: NSURL.self) { object, error in
                if let error { continuation.resume(throwing: error); return }
                guard let value = object as? URL else { continuation.resume(throwing: WTShareError.unreadableItem); return }
                continuation.resume(returning: value)
            }
        }
    }

    private func loadText(_ provider: NSItemProvider) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadObject(ofClass: NSString.self) { object, error in
                if let error { continuation.resume(throwing: error); return }
                guard let value = object as? String else { continuation.resume(throwing: WTShareError.unreadableItem); return }
                continuation.resume(returning: value)
            }
        }
    }

    private func stageText(_ text: String, suggestedName: String) throws -> URL {
        let url = uniqueStagingURL(suggestedName: suggestedName)
        try Data(text.utf8).write(to: url, options: .atomic)
        return url
    }

    private func uniqueStagingURL(suggestedName: String) -> URL {
        let clean = WTTransferProtocol.safeFileName(suggestedName)
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("WTShareOutgoing", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("\(UUID().uuidString)-\(clean)")
    }

    private func sharedPairingCode() -> String? {
        guard let group = Bundle.main.object(forInfoDictionaryKey: "WTAppGroupIdentifier") as? String,
              let defaults = UserDefaults(suiteName: group) else { return nil }
        return defaults.string(forKey: WTSharedPreferenceKey.transferPairingCode)
    }
}

private struct WTQuickSendShareContainer: View {
    @ObservedObject var model: WTQuickSendShareModel
    let onCancel: () -> Void
    let onSend: (WTPeerDevice) -> Void
    let onRetry: () -> Void

    var body: some View {
        WTQuickSendShareView(
            items: model.items,
            peers: model.peers,
            isLoading: model.isLoading,
            isSending: model.isSending,
            statusText: model.statusText,
            errorText: model.errorText,
            progress: model.overallProgress,
            canRetry: model.canRetry,
            onCancel: onCancel,
            onSend: onSend,
            onRetry: onRetry
        )
    }
}

private enum WTShareError: LocalizedError {
    case noItems
    case unreadableItem
    var errorDescription: String? {
        switch self {
        case .noItems: return "没有可发送的内容"
        case .unreadableItem: return "无法读取分享内容"
        }
    }
}
#endif
