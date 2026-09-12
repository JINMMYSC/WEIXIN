import Foundation

protocol PinyinEngine {
    func candidates(for composingText: String) -> [InputCandidate]
}

struct EmptyPinyinEngine: PinyinEngine {
    func candidates(for composingText: String) -> [InputCandidate] { [] }
}
