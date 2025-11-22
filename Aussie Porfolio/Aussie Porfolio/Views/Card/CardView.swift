//
//  CardView.swift
//  Aussie Porfolio
//
//  Created by Zibo Lin on 22/11/2025.
//

import UIKit
import SnapKit

// MARK: - CardView (gradient styles)

enum CardStyle { case green, red, blue, neutral, purple, cashFlowStyle }

final class CardView: UIView {
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    let subtitleLabel = UILabel()
    private let gradient = CAGradientLayer()
    var style: CardStyle { didSet { applyStyle() } }

    init(style: CardStyle = .neutral) {
        self.style = style
        super.init(frame: .zero)
        configure()
        applyStyle()
    }

    required init?(coder: NSCoder) {
        self.style = .neutral
        super.init(coder: coder)
        configure()
        applyStyle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }

    public func configure() {
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 16
        layer.masksToBounds = true

        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint   = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradient, at: 0)

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemGray

        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel

        valueLabel.font = .systemFont(ofSize: 26, weight: .bold)
        valueLabel.textColor = .label

        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .tertiaryLabel

        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(subtitleLabel)

        iconImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(12)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView.snp.centerY)
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.right.equalToSuperview().inset(12)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
        }
    }

    public func applyStyle() {
        switch style {
        case .green:
            gradient.isHidden = false
            gradient.colors = [UIColor.systemGreen.cgColor,
                               UIColor.systemGreen.withAlphaComponent(0.85).cgColor]
            titleLabel.textColor = .white
            valueLabel.textColor = .white
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)

        case .red:
            gradient.isHidden = false
            gradient.colors = [UIColor.systemRed.cgColor, UIColor.systemPink.cgColor]
            titleLabel.textColor = .white
            valueLabel.textColor = .white
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)

        case .blue:
            gradient.isHidden = false
            gradient.colors = [UIColor.systemBlue.cgColor, UIColor.systemIndigo.cgColor]
            titleLabel.textColor = .white
            valueLabel.textColor = .white
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)

        case .purple:
            gradient.isHidden = false
            gradient.colors = [UIColor.systemPurple.cgColor, UIColor.systemTeal.cgColor]
            titleLabel.textColor = .white
            valueLabel.textColor = .white
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)

        case .neutral:
            gradient.isHidden = true
            backgroundColor = .secondarySystemGroupedBackground
            titleLabel.textColor = .secondaryLabel
            valueLabel.textColor = .label
            subtitleLabel.textColor = .tertiaryLabel
        case .cashFlowStyle:
            gradient.isHidden = false
            gradient.colors = [UIColor.systemPurple.cgColor, UIColor.systemTeal.cgColor]
            titleLabel.textColor = .white
            valueLabel.textColor = .white
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        }
    }
}
