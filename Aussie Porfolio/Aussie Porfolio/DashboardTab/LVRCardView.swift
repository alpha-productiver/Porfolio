import UIKit
import SnapKit

final class LVRCardView: UIView {

    private let circularProgress = CircularProgressView()

    private let assetLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()

    private let assetTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .secondaryLabel
        label.text = "Assets"
        label.textAlignment = .center
        return label
    }()

    private let debtLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemRed
        label.textAlignment = .center
        return label
    }()

    private let debtTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .secondaryLabel
        label.text = "Debts"
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.text = "Property LVR"
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 16

        addSubview(titleLabel)
        addSubview(circularProgress)
        addSubview(assetTitleLabel)
        addSubview(assetLabel)
        addSubview(debtTitleLabel)
        addSubview(debtLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
        }

        circularProgress.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(140)
        }

        assetTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(circularProgress.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(40)
        }

        assetLabel.snp.makeConstraints { make in
            make.top.equalTo(assetTitleLabel.snp.bottom).offset(4)
            make.centerX.equalTo(assetTitleLabel)
        }

        debtTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(circularProgress.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-40)
        }

        debtLabel.snp.makeConstraints { make in
            make.top.equalTo(debtTitleLabel.snp.bottom).offset(4)
            make.centerX.equalTo(debtTitleLabel)
            make.bottom.equalToSuperview().inset(16)
        }
    }

    func configure(lvr: Double, assetValue: String, debtValue: String) {
        let lvrProgress = CGFloat(lvr / 100)
        circularProgress.setProgress(lvrProgress, animated: true)

        assetLabel.text = assetValue
        debtLabel.text = debtValue
    }
}
