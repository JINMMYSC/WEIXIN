import UIKit

final class KeyboardViewController: UIInputViewController {
    private let sessionBridge = KeyboardSessionBridge()
    private let compositionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground

        compositionLabel.text = ""
        compositionLabel.font = .monospacedSystemFont(ofSize: 20, weight: .medium)
        compositionLabel.textAlignment = .center
        compositionLabel.accessibilityIdentifier = "composition-text"

        let next = UIButton(type: .system)
        next.setTitle("切换键盘", for: .normal)
        next.accessibilityIdentifier = "next-keyboard"
        next.addTarget(self, action: #selector(switchKeyboard), for: .touchUpInside)

        let rows = ["qwertyuiop", "asdfghjkl", "zxcvbnm"].map { makeKeyRow($0) }
        let delete = UIButton(type: .system)
        delete.setTitle("删除", for: .normal)
        delete.addTarget(self, action: #selector(deleteBackward), for: .touchUpInside)
        let commit = UIButton(type: .system)
        commit.setTitle("提交", for: .normal)
        commit.addTarget(self, action: #selector(commitPending), for: .touchUpInside)
        let controls = UIStackView(arrangedSubviews: [delete, commit, next])
        controls.distribution = .fillEqually
        var arranged: [UIView] = [compositionLabel]
        arranged.append(contentsOf: rows)
        arranged.append(controls)
        let stack = UIStackView(arrangedSubviews: arranged)
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

    private func makeKeyRow(_ letters: String) -> UIStackView {
        let buttons = letters.map { letter -> UIButton in
            let button = UIButton(type: .system)
            button.setTitle(String(letter), for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 19)
            button.addAction(UIAction { [weak self] _ in
                self?.handleInputEvent(.insert(String(letter)))
            }, for: .touchUpInside)
            return button
        }
        let row = UIStackView(arrangedSubviews: buttons)
        row.distribution = .fillEqually
        row.spacing = 4
        return row
    }

    @objc private func switchKeyboard() {
        advanceToNextInputMode()
    }

    @objc private func deleteBackward() {
        handleInputEvent(.deleteBackward)
    }

    @objc private func commitPending() {
        handleInputEvent(.commitPending)
    }

    func handleInputEvent(_ event: InputEvent) {
        let output = sessionBridge.handle(event)
        if let committedText = output.committedText {
            textDocumentProxy.insertText(committedText)
        }
        textDocumentProxy.setMarkedText(
            output.snapshot.composingText,
            selectedRange: NSRange(location: output.snapshot.composingText.utf16.count, length: 0)
        )
        compositionLabel.text = output.snapshot.composingText
    }
}
