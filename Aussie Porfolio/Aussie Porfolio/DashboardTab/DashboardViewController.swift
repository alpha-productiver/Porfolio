import UIKit
import SnapKit

// MARK: - DashboardViewController

final class DashboardViewController: UIViewController {
    var viewModel: DashboardViewModel!
    weak var coordinator: MainCoordinator?

    // MARK: UI

    private let scrollView = UIScrollView()
    private let stackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 16
        v.distribution = .fill
        return v
    }()

    // Big cards
    private lazy var portfolioValueCard: CardView = {
        let c = CardView(style: .green)
        c.titleLabel.text = "Total Portfolio Value"
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        c.iconImageView.image = UIImage(systemName: "chart.line.uptrend.xyaxis", withConfiguration: config)
        c.iconImageView.tintColor = .white
        return c
    }()

    private lazy var liabilitiesCard: CardView = {
        let c = CardView(style: .red)
        c.titleLabel.text = "Total Liabilities"
        c.subtitleLabel.text = "No liabilities recorded"
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        c.iconImageView.image = UIImage(systemName: "creditcard.fill", withConfiguration: config)
        c.iconImageView.tintColor = .white
        return c
    }()

    private lazy var netWorthCard: CardView = {
        let c = CardView(style: .blue)
        c.titleLabel.text = "Net Worth"
        c.subtitleLabel.text = "Positive net worth"
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        c.iconImageView.image = UIImage(systemName: "chart.bar.fill", withConfiguration: config)
        c.iconImageView.tintColor = .white
        return c
    }()

    // Mini cards (neutral style)
    private lazy var propertiesCard = makeMiniCard(title: "Properties", icon: "house.fill")
    private lazy var assetsCard     = makeMiniCard(title: "Other Assets", icon: "dollarsign.circle.fill")
    private lazy var cashCard       = makeMiniCard(title: "Cash", icon: "banknote.fill")
    private lazy var allocationCard = makeMiniCard(title: "Allocation", icon: "chart.pie.fill")

    // LVR Card
    private lazy var lvrCard = LVRCardView()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Portfolio"
        view.backgroundColor = .systemGroupedBackground

        buildLayout()
        bindViewModel()
    }

    // MARK: Layout (SnapKit)

    private func buildLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }

        // Use contentLayoutGuide/frameLayoutGuide for proper scrolling
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide).inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
            make.width.equalTo(scrollView.frameLayoutGuide).offset(-32) // frame width minus horizontal insets
        }

        // Order & rows
        stackView.addArrangedSubview(portfolioValueCard)

        let row1 = UIStackView(arrangedSubviews: [propertiesCard, assetsCard])
        row1.axis = .horizontal; row1.spacing = 12; row1.distribution = .fillEqually
        stackView.addArrangedSubview(row1)

        let row2 = UIStackView(arrangedSubviews: [cashCard, allocationCard])
        row2.axis = .horizontal; row2.spacing = 12; row2.distribution = .fillEqually
        stackView.addArrangedSubview(row2)

        stackView.addArrangedSubview(lvrCard)
        stackView.addArrangedSubview(liabilitiesCard)
        stackView.addArrangedSubview(netWorthCard)

        // Heights to match the mock
        [portfolioValueCard, liabilitiesCard, netWorthCard].forEach {
            $0.snp.makeConstraints { $0.height.equalTo(160) }
        }
        [propertiesCard, assetsCard, cashCard, allocationCard].forEach {
            $0.snp.makeConstraints { $0.height.equalTo(110) }
        }
        lvrCard.snp.makeConstraints { $0.height.equalTo(280) }
    }

    // MARK: Binding

    private func bindViewModel() {
        viewModel.onDataChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
        updateUI()
    }

    private func updateUI() {
        // Portfolio value
        portfolioValueCard.valueLabel.text = viewModel.portfolioValueText
        portfolioValueCard.subtitleLabel.text = viewModel.portfolioSubtitleText

        // Net worth
        netWorthCard.valueLabel.text = viewModel.netWorthText
        netWorthCard.subtitleLabel.text = viewModel.netWorthSubtitleText

        // Liabilities
        liabilitiesCard.valueLabel.text = viewModel.liabilitiesText
        liabilitiesCard.subtitleLabel.text = viewModel.liabilitiesSubtitleText

        // Properties
        propertiesCard.valueLabel.text = viewModel.propertiesValueText
        propertiesCard.valueLabel.textColor = .systemBlue
        propertiesCard.subtitleLabel.text = viewModel.propertiesCountText

        // Assets
        assetsCard.valueLabel.text = viewModel.assetsValueText
        assetsCard.valueLabel.textColor = .systemGreen
        assetsCard.subtitleLabel.text = viewModel.assetsCountText

        // Cash
        cashCard.valueLabel.text = viewModel.cashValueText
        cashCard.valueLabel.textColor = .systemGreen
        cashCard.subtitleLabel.text = viewModel.cashCountText

        // Allocation
        allocationCard.valueLabel.text = viewModel.allocationPercentageText
        allocationCard.subtitleLabel.text = viewModel.allocationSubtitleText

        // LVR Card
        lvrCard.configure(
            lvr: viewModel.lvrPercentage,
            assetValue: viewModel.lvrAssetText,
            debtValue: viewModel.lvrDebtText
        )
    }

    // MARK: Actions

    private func makeMiniCard(title: String, icon: String) -> CardView {
        let c = CardView(style: .neutral)
        c.titleLabel.text = title
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        c.iconImageView.image = UIImage(systemName: icon, withConfiguration: config)
        c.iconImageView.tintColor = .systemGray
        let tap = UITapGestureRecognizer(target: self, action: #selector(miniTapped(_:)))
        c.addGestureRecognizer(tap)
        return c
    }

    @objc private func miniTapped(_ gr: UITapGestureRecognizer) {
        guard let card = gr.view as? CardView else { return }
        switch card.titleLabel.text {
        case "Properties": coordinator?.showProperties()
        case "Other Assets": coordinator?.showAssets()
        case "Cash": coordinator?.showCash()
        default: break
        }
    }
}
