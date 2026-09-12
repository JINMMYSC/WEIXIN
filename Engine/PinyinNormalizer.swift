import Foundation

struct PinyinNormalizer {
    func normalize(_ input: String) -> String {
        var result = ""
        var previousWasSeparator = false
        for scalar in input.lowercased().unicodeScalars {
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
