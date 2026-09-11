import UIKit

final class KeyboardViewController: UIInputViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground

        let status = UILabel()
        status.text = "输入引擎尚未接入"
        status.font = .preferredFont(forTextStyle: .headline)
        status.numberOfLines = 0
        status.textAlignment = .center

        let next = UIButton(type: .system)
        next.setTitle("切换键盘", for: .normal)
        next.accessibilityIdentifier = "next-keyboard"
        next.addTarget(self, action: #selector(switchKeyboard), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [status, next])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        let height = view.heightAnchor.constraint(equalToConstant: 216)
        height.priority = .defaultHigh
        height.isActive = true
    }

    @objc private func switchKeyboard() {
        advanceToNextInputMode()
    }
}
