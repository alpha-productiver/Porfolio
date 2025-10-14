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

// MARK: - Asset Card Data Protocol

protocol AssetCardData {
    var cardTitle: String { get }
    var cardSubtitle: String { get }
    var cardValue: String { get }
    var cardDetail: String { get }
}

// MARK: - Asset Card View

final class AssetCardView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .systemGreen
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(valueLabel)
        addSubview(detailLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            valueLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            detailLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    func configure(with data: AssetCardData) {
        titleLabel.text = data.cardTitle
        subtitleLabel.text = data.cardSubtitle
        valueLabel.text = data.cardValue
        detailLabel.text = data.cardDetail
    }
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
