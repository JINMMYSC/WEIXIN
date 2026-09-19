import SwiftUI
import Foundation

/// 用户自填的 DeepSeek 链路设置。
///
/// Key 由用户在本页输入，保存在 App Group 容器里供键盘扩展读取；仓库、构建参数和 CI 日志
/// 都不会出现它。留空时 AI、翻译、纠错、润色、拆词继续走本地实现。
public struct WTSettingsDeepSeekSection: View {
    @State private var apiKey = ""
    @State private var baseURL = WTDeepSeekConfiguration.defaultBaseURL
    @State private var model = WTDeepSeekConfiguration.defaultModel
    @State private var enabled = true
    @State private var status: String?

    private var appGroupID: String {
        (Bundle.main.object(forInfoDictionaryKey: "WTAppGroupIdentifier") as? String) ?? "group.7518554"
    }

    public init() {}

    public var body: some View {
        Section {
            Toggle("启用 DeepSeek 服务", isOn: $enabled)

            SecureField("API Key（sk-…）", text: $apiKey)
                .disableAutocorrection(true)
                .accessibilityIdentifier("host.deepseek.key")

            TextField("服务地址", text: $baseURL)
                .disableAutocorrection(true)
                .accessibilityIdentifier("host.deepseek.baseurl")

            TextField("模型", text: $model)
                .disableAutocorrection(true)
                .accessibilityIdentifier("host.deepseek.model")

            Button("保存并启用") { save() }
                .accessibilityIdentifier("host.deepseek.save")

            if let status {
                Text(status)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("DeepSeek 服务")
        } footer: {
            Text("Key 只保存在本机 App Group 容器，用于 AI 问答、翻译、纠错、润色和拆词；不会写入仓库或构建产物。留空则这些能力保持本地实现。")
        }
        .onAppear(perform: load)
    }

    private func load() {
        let configuration = WTDeepSeekConfigurationStore.load(appGroupIdentifier: appGroupID)
        apiKey = configuration.apiKey
        baseURL = configuration.baseURL
        model = configuration.model
        enabled = configuration.isEnabled
        status = configuration.isConfigured ? "已配置：输入法将使用该服务" : nil
    }

    private func save() {
        let configuration = WTDeepSeekConfiguration(
            apiKey: apiKey.trimmingCharacters(in: .whitespacesAndNewlines),
            baseURL: baseURL.trimmingCharacters(in: .whitespacesAndNewlines),
            model: model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? WTDeepSeekConfiguration.defaultModel
                : model.trimmingCharacters(in: .whitespacesAndNewlines),
            isEnabled: enabled
        )
        let saved = WTDeepSeekConfigurationStore.save(configuration, appGroupIdentifier: appGroupID)
        if !saved {
            status = "保存失败：无法写入共享容器"
        } else if configuration.isConfigured {
            status = "已保存。重新打开键盘后生效。"
        } else {
            status = "已保存，但未填写 Key，功能仍走本地实现。"
        }
    }
}
