import Foundation

public enum WTProviderConfigurationStore {
    public static func load(from url: URL?) -> WTProviderConfiguration {
        guard let url,
              let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(WTProviderConfiguration.self, from: data) else { return .init() }
        return config
    }

    @discardableResult
    public static func save(_ configuration: WTProviderConfiguration, to url: URL?) -> Bool {
        guard let url else { return false }
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(configuration)
            try data.write(to: url, options: .atomic)
            return true
        } catch {
            return false
        }
    }
}
