import SwiftUI
import UIKit
import PhotosUI
import UniformTypeIdentifiers

public enum WTHostPhase4Route: String {
    case quickSend
    case picture
    case voiceUnavailable
}

public struct WTHostPhase4RouteView: View {
    let route: WTHostPhase4Route
    let appGroupIdentifier: String
    @Environment(\.dismiss) private var dismiss
    @State private var showDocumentPicker = false
    @State private var showPhotoPicker = false
    @State private var stagedName: String?
    @State private var failure: String?

    public init(route: WTHostPhase4Route, appGroupIdentifier: String) {
        self.route = route
        self.appGroupIdentifier = appGroupIdentifier
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 18) {
                Spacer()
                WTSemanticGlyph(name: icon)
                    .font(.system(size: 52, weight: .light))
                    .foregroundStyle(Color(red: 35/255, green: 200/255, blue: 145/255))
                Text(title).font(.system(size: 18, weight: .semibold))
                Text(detail).font(.system(size: 13)).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 36)
                if let stagedName {
                    Text("已准备：\(stagedName)").font(.system(size: 13, weight: .medium)).foregroundStyle(Color(red: 35/255, green: 200/255, blue: 145/255))
                }
                if let failure {
                    Text(failure).font(.system(size: 12)).foregroundStyle(.red).multilineTextAlignment(.center).padding(.horizontal, 28)
                }
                if route == .quickSend {
                    Button("选择文件") { showDocumentPicker = true }.buttonStyle(.borderedProminent)
                } else if route == .picture {
                    Button("选择图片") { showPhotoPicker = true }.buttonStyle(.borderedProminent)
                }
                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("完成") { dismiss() } } }
        }
        .sheet(isPresented: $showDocumentPicker) {
            WTPhase4DocumentPicker { url in stage(url: url, kind: "quick-send") }
        }
        .sheet(isPresented: $showPhotoPicker) {
            WTPhase4PhotoPicker { data, suggestedName in stage(data: data, name: suggestedName, kind: "picture") }
        }
    }

    private var icon: String {
        switch route {
        case .quickSend: return "paperplane.circle"
        case .picture: return "photo.on.rectangle.angled"
        case .voiceUnavailable: return "waveform.slash"
        }
    }

    private var title: String {
        switch route {
        case .quickSend: return "隔空传送"
        case .picture: return "图片"
        case .voiceUnavailable: return "语音输入"
        }
    }

    private var detail: String {
        switch route {
        case .quickSend: return "选择要传送的文件。文件会进入 App Group 的待发送区，返回键盘后继续设备选择。"
        case .picture: return "选择图片并放入共享待发送区，返回键盘后继续操作。"
        case .voiceUnavailable: return "无法打开语音请求，请返回键盘重新发起。"
        }
    }

    private func stage(url: URL, kind: String) {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        do {
            let data = try Data(contentsOf: url)
            try stage(data: data, name: url.lastPathComponent, kind: kind)
        } catch {
            failure = error.localizedDescription
        }
    }

    private func stage(data: Data, name: String, kind: String) throws {
        guard let root = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            throw CocoaError(.fileNoSuchFile)
        }
        let directory = root.appendingPathComponent("WeTypeReplica/Phase4Handoff", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let safeName = name.isEmpty ? UUID().uuidString : name
        let target = directory.appendingPathComponent(safeName)
        try data.write(to: target, options: .atomic)
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        defaults?.set(target.path, forKey: "wt.phase4.\(kind).path")
        defaults?.set(safeName, forKey: "wt.phase4.\(kind).name")
        defaults?.set(Date().timeIntervalSince1970, forKey: "wt.phase4.\(kind).timestamp")
        stagedName = safeName
        failure = nil
    }
}

private struct WTPhase4DocumentPicker: UIViewControllerRepresentable {
    let completion: (URL) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(completion: completion) }
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.data], asCopy: true)
        controller.allowsMultipleSelection = false
        controller.delegate = context.coordinator
        return controller
    }
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let completion: (URL) -> Void
        init(completion: @escaping (URL) -> Void) { self.completion = completion }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first { completion(url) }
        }
    }
}

private struct WTPhase4PhotoPicker: UIViewControllerRepresentable {
    let completion: (Data, String) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(completion: completion) }
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let completion: (Data, String) -> Void
        init(completion: @escaping (Data, String) -> Void) { self.completion = completion }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let result = results.first else { return }
            let provider = result.itemProvider
            let type = UTType.image.identifier
            guard provider.hasItemConformingToTypeIdentifier(type) else { return }
            provider.loadDataRepresentation(forTypeIdentifier: type) { data, _ in
                guard let data else { return }
                DispatchQueue.main.async { self.completion(data, "image-\(UUID().uuidString).jpg") }
            }
        }
    }
}
