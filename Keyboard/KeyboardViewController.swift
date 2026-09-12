import UIKit

final class KeyboardViewController: UIInputViewController {
    private let sessionBridge = KeyboardSessionBridge()
    private let compositionLabel = UILabel()
    private let candidateStack = UIStackView()
    private let theme = KeyboardTheme.system
    private var candidatePager = CandidatePager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme.backgroundColor

        compositionLabel.text = ""
        compositionLabel.font = .monospacedSystemFont(ofSize: 20, weight: .medium)
        compositionLabel.textAlignment = .center
        compositionLabel.accessibilityIdentifier = "composition-text"

        candidateStack.axis = .horizontal
        candidateStack.spacing = 12
        candidateStack.distribution = .fillEqually
        candidateStack.accessibilityIdentifier = "candidate-bar"

        let previousCandidates = UIButton(type: .system)
        previousCandidates.setTitle("‹", for: .normal)
        previousCandidates.accessibilityIdentifier = "previous-candidates"
        previousCandidates.addTarget(self, action: #selector(previousCandidatePage), for: .touchUpInside)
        let nextCandidates = UIButton(type: .system)
        nextCandidates.setTitle("›", for: .normal)
        nextCandidates.accessibilityIdentifier = "next-candidates"
        nextCandidates.addTarget(self, action: #selector(nextCandidatePage), for: .touchUpInside)
        let candidateRow = UIStackView(arrangedSubviews: [previousCandidates, candidateStack, nextCandidates])
        candidateRow.axis = .horizontal
        candidateRow.spacing = 4
        candidateRow.alignment = .fill
        candidateRow.distribution = .fill
        candidateStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        previousCandidates.setContentHuggingPriority(.required, for: .horizontal)
        nextCandidates.setContentHuggingPriority(.required, for: .horizontal)

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
        let space = UIButton(type: .system)
        space.setTitle("空格", for: .normal)
        space.addTarget(self, action: #selector(insertSpace), for: .touchUpInside)
        let enter = UIButton(type: .system)
        enter.setTitle("换行", for: .normal)
        enter.addTarget(self, action: #selector(insertNewline), for: .touchUpInside)
        let controls = UIStackView(arrangedSubviews: [delete, space, enter, commit, next])
        controls.distribution = .fillEqually
        var arranged: [UIView] = [compositionLabel, candidateRow]
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
            button.backgroundColor = theme.keyColor
            button.setTitleColor(theme.keyTextColor, for: .normal)
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

    @objc private func insertSpace() {
        handleInputEvent(.insert(" "))
    }

    @objc private func insertNewline() {
        handleInputEvent(.commitPending)
        textDocumentProxy.insertText("\n")
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
        updateCandidates(output.snapshot.candidates)
    }

    func showCandidates(_ candidates: [InputCandidate]) {
        candidatePager.replace(with: candidates)
        updateCandidates()
    }

    private func updateCandidates(_ candidates: [InputCandidate]? = nil) {
        if let candidates { candidatePager.replace(with: candidates) }
        candidateStack.arrangedSubviews.forEach { candidateStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        for candidate in candidatePager.visibleCandidates {
            let button = UIButton(type: .system)
            button.setTitle(candidate.text, for: .normal)
            button.setTitleColor(theme.candidateTextColor, for: .normal)
            button.addAction(UIAction { [weak self] _ in
                self?.selectCandidate(candidate)
            }, for: .touchUpInside)
            candidateStack.addArrangedSubview(button)
        }
    }

    @objc private func previousCandidatePage() {
        candidatePager.previousPage()
        updateCandidates()
    }

    @objc private func nextCandidatePage() {
        candidatePager.nextPage()
        updateCandidates()
    }

    private func selectCandidate(_ candidate: InputCandidate) {
        let output = sessionBridge.selectCandidate(candidate)
        textDocumentProxy.insertText(output.committedText ?? candidate.text)
        textDocumentProxy.setMarkedText("", selectedRange: NSRange(location: 0, length: 0))
        compositionLabel.text = output.snapshot.composingText
        updateCandidates(output.snapshot.candidates)
    }
}
