import UIKit

struct KeyboardTheme {
    let backgroundColor: UIColor
    let keyColor: UIColor
    let keyTextColor: UIColor
    let candidateTextColor: UIColor

    static let system = KeyboardTheme(
        backgroundColor: .secondarySystemBackground,
        keyColor: .systemBackground,
        keyTextColor: .label,
        candidateTextColor: .label
    )
}
