import UIKit

// MARK: - Form Section Header

final class FormSectionHeader: UILabel {
    init(_ text: String) {
        super.init(frame: .zero)
        self.text = text
        font = .systemFont(ofSize: 15, weight: .semibold)
        textColor = .label
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Divider

final class Divider: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .separator
        heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Labeled Field

final class LabeledField: UIStackView {
    let titleLabel = UILabel()
    let textField = UITextField()

    init(title: String, placeholder: String, keyboard: UIKeyboardType = .default) {
        super.init(frame: .zero)
        axis = .vertical
        spacing = 6
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .secondaryLabel

        textField.borderStyle = .none
        textField.placeholder = placeholder
        textField.keyboardType = keyboard
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.separator.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 40))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 40))
        textField.rightViewMode = .always
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true

        addArrangedSubview(titleLabel)
        addArrangedSubview(textField)
    }
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
