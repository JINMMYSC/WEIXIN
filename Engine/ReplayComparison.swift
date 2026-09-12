import Foundation

struct ReplayDifference: Equatable {
    let step: Int
    let expected: InputSnapshot?
    let actual: InputSnapshot?
}

struct ReplayComparator {
    func differences(expected: [InputSnapshot], actual: [InputSnapshot]) -> [ReplayDifference] {
        let count = max(expected.count, actual.count)
        return (0..<count).compactMap { index in
            let expectedSnapshot = index < expected.count ? expected[index] : nil
            let actualSnapshot = index < actual.count ? actual[index] : nil
            guard expectedSnapshot != actualSnapshot else { return nil }
            return ReplayDifference(step: index, expected: expectedSnapshot, actual: actualSnapshot)
        }
    }
}
