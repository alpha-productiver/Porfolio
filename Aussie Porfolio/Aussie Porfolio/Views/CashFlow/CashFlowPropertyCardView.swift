//
//  CashFlowPropertyCardView.swift
//  Aussie Porfolio
//
//  Created by Zibo Lin on 23/11/2025.
//

import UIKit
import SnapKit

// MARK: - Property Card

public final class CashFlowPropertyCardView: UIView {
    private let iconContainer = UIView()
    private let iconView = UIImageView()

    private let nameLabel = UILabel()
    private let tagLabel = PaddingLabel()

    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))

    private let incomeTitleLabel = UILabel()
    private let incomeValueLabel = UILabel()

    private let expensesTitleLabel = UILabel()
    private let expensesValueLabel = UILabel()

    private let netTitleLabel = UILabel()
    private let netValueLabel = UILabel()

    private let nextPaymentTitleLabel = UILabel()
    private let nextPaymentValueLabel = UILabel()
    private var onTap: (() -> Void)?

    init() {
        super.init(frame: .zero)
        setup()
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 24
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 16

        iconContainer.layer.cornerRadius = 22
        iconContainer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)

        iconView.tintColor = .systemGreen
        iconView.contentMode = .scaleAspectFit

        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .label

        tagLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        tagLabel.textColor = .systemGreen
        tagLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        tagLabel.layer.cornerRadius = 10
        tagLabel.clipsToBounds = true
        tagLabel.textAlignment = .center
        tagLabel.horizontalPadding = 8
        tagLabel.verticalPadding = 2
        tagLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        tagLabel.setContentHuggingPriority(.required, for: .horizontal)

        chevronView.tintColor = .tertiaryLabel
        chevronView.contentMode = .scaleAspectFit

        [incomeTitleLabel, expensesTitleLabel, netTitleLabel, nextPaymentTitleLabel].forEach {
            $0.font = UIFont.preferredFont(forTextStyle: .caption1)
            $0.textColor = .secondaryLabel
        }

        incomeTitleLabel.text = "Income"
        expensesTitleLabel.text = "Expenses"
        netTitleLabel.text = "Net"
        nextPaymentTitleLabel.text = "Next payment"

        incomeValueLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        incomeValueLabel.textColor = .systemGreen

        expensesValueLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        expensesValueLabel.textColor = .systemRed

        netValueLabel.font = .systemFont(ofSize: 15, weight: .semibold)

        nextPaymentValueLabel.font = .systemFont(ofSize: 13, weight: .regular)
        nextPaymentValueLabel.textColor = .secondaryLabel
        nextPaymentValueLabel.numberOfLines = 0
    }

    private func build() {
        iconContainer.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.center.equalTo(iconContainer)
            make.width.height.equalTo(22)
        }
        iconContainer.snp.makeConstraints { make in
            make.width.height.equalTo(44)
        }

        let nameAndTagStack = UIStackView(arrangedSubviews: [nameLabel, tagLabel])
        nameAndTagStack.axis = .horizontal
        nameAndTagStack.alignment = .leading
        nameAndTagStack.spacing = 8
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let spacer = UIView()
        let headerRightStack = UIStackView(arrangedSubviews: [nameAndTagStack, spacer, chevronView])
        headerRightStack.axis = .horizontal
        headerRightStack.alignment = .center
        headerRightStack.spacing = 8

        chevronView.snp.makeConstraints { make in
            make.width.equalTo(10)
        }

        let headerStack = UIStackView(arrangedSubviews: [iconContainer, headerRightStack])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 12

        let incomeStack = UIStackView(arrangedSubviews: [incomeTitleLabel, incomeValueLabel])
        incomeStack.axis = .vertical
        incomeStack.spacing = 2

        let expensesStack = UIStackView(arrangedSubviews: [expensesTitleLabel, expensesValueLabel])
        expensesStack.axis = .vertical
        expensesStack.spacing = 2

        let midRow = UIStackView(arrangedSubviews: [incomeStack, UIView(), expensesStack])
        midRow.axis = .horizontal
        midRow.alignment = .top
        midRow.spacing = 12

        let divider = UIView()
        divider.backgroundColor = UIColor.systemGray5
        divider.snp.makeConstraints { $0.height.equalTo(1) }

        let netStack = UIStackView(arrangedSubviews: [netTitleLabel, netValueLabel])
        netStack.axis = .vertical
        netStack.spacing = 2

        let nextPaymentStack = UIStackView(arrangedSubviews: [nextPaymentTitleLabel, nextPaymentValueLabel])
        nextPaymentStack.axis = .vertical
        nextPaymentStack.spacing = 2

        let bottomRow = UIStackView(arrangedSubviews: [netStack, UIView(), nextPaymentStack])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .top
        bottomRow.spacing = 12

        let verticalStack = UIStackView(arrangedSubviews: [headerStack, midRow, divider, bottomRow])
        verticalStack.axis = .vertical
        verticalStack.spacing = 12

        addSubview(verticalStack)
        verticalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }
    }

    func configure(with item: CashFlowPropertyItem, onTap: (() -> Void)? = nil) {
        self.onTap = onTap
        iconView.image = UIImage(systemName: item.iconSystemName)

        let accent = item.netIsPositive ? UIColor.systemGreen : UIColor.systemRed
        iconContainer.backgroundColor = accent.withAlphaComponent(0.1)
        iconView.tintColor = accent

        nameLabel.text = item.name
        tagLabel.text = item.tag.uppercased()

        incomeValueLabel.text = item.incomeText
        expensesValueLabel.text = item.expensesText

        netValueLabel.text = item.netText
        netValueLabel.textColor = item.netIsPositive ? .systemGreen : .systemRed

        nextPaymentValueLabel.text = item.nextPaymentText

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        onTap?()
    }
}
