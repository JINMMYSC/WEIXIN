import Foundation

final class ResourceLoader {
    enum LoadError: Error, Equatable {
        case missingResource(String)
        case invalidResource(String)
    }

    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func loadIndexedResource(named name: String) throws -> IndexedResource {
        guard let url = bundle.url(forResource: name, withExtension: "bin") else {
            throw LoadError.missingResource(name)
        }
        do {
            return try IndexedResource(data: Data(contentsOf: url))
        } catch {
            throw LoadError.invalidResource(name)
        }
    }
}
