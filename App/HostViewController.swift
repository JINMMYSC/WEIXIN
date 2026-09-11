import UIKit

final class HostViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let title = UILabel()
        title.text = "离线键盘重建实验"
        title.font = .preferredFont(forTextStyle: .title1)
        title.adjustsFontForContentSizeCategory = true
        title.numberOfLines = 0

        let detail = UILabel()
        detail.text = "当前为基础工程，输入引擎尚未接入。\n可在下方输入框切换原版键盘并记录采样。"
        detail.font = .preferredFont(forTextStyle: .body)
        detail.adjustsFontForContentSizeCategory = true
        detail.numberOfLines = 0

        let input = UITextView()
        input.accessibilityIdentifier = "sampling-input"
        input.accessibilityLabel = "采样输入框"
        input.font = .preferredFont(forTextStyle: .body)
        input.adjustsFontForContentSizeCategory = true
        input.backgroundColor = .secondarySystemBackground
        input.layer.cornerRadius = 12
        input.autocorrectionType = .no
        input.autocapitalizationType = .none

        let stack = UIStackView(arrangedSubviews: [title, detail, input])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -12)
        ])
    }
}

