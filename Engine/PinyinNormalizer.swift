import Foundation

struct PinyinNormalizer {
    func normalize(_ input: String) -> String {
        var result = ""
        var previousWasSeparator = false
        let umlautU = CharacterSet(charactersIn: "üǖǘǚǜ")
        let mapped = input.lowercased().unicodeScalars.map { scalar -> String in
            umlautU.contains(scalar) ? "v" : String(scalar)
        }.joined()
        let folded = mapped.folding(options: .diacriticInsensitive, locale: Locale(identifier: "en_US_POSIX"))
        for scalar in folded.unicodeScalars {
            if (scalar.value >= 97 && scalar.value <= 122) {
                result.unicodeScalars.append(scalar)
                previousWasSeparator = false
            } else if scalar.value == 39 && !result.isEmpty && !previousWasSeparator {
                result.unicodeScalars.append(scalar)
                previousWasSeparator = true
            }
        }
        if previousWasSeparator { result.removeLast() }
        return result
    }
}
