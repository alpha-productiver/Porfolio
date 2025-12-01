import UIKit
import SnapKit

final class CashFlowViewController: UIViewController {
    var viewModel: CashFlowViewModel!
    weak var coordinator: MainCoordinator?

    private let scrollView = UIScrollView()
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        return stack
    }()

    private let monthlyCard: CardView = {
        let c = CardView(style: .neutral)
        c.titleLabel.text = "Monthly Cash Flow"
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        c.iconImageView.image = UIImage(systemName: "banknote.fill", withConfiguration: config)
        return c
    }()

    private let annualCard: CardView = {
        let c = CardView(style: .neutral)
        c.titleLabel.text = "Annual Cash Flow"
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        c.iconImageView.image = UIImage(systemName: "banknote.fill", withConfiguration: config)
        return c
    }()

    private let propertiesHeader: UILabel = {
        let label = UILabel()
        label.text = "Properties"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let propertiesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No properties yet"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cash Flow"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        buildLayout()
        bind()
    }

    private func buildLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        scrollView.alwaysBounceVertical = true

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }

        contentStack.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        let statRow = UIStackView(arrangedSubviews: [monthlyCard, annualCard])
        statRow.axis = .horizontal
        statRow.spacing = 12
        statRow.distribution = .fillEqually
        contentStack.addArrangedSubview(statRow)
        [monthlyCard, annualCard].forEach { card in
            card.snp.makeConstraints { $0.height.equalTo(140) }
        }

        let propertiesContainer = UIView()
        propertiesContainer.backgroundColor = .clear
        propertiesContainer.addSubview(propertiesHeader)
        propertiesContainer.addSubview(propertiesStack)
        propertiesContainer.addSubview(emptyLabel)

        propertiesHeader.snp.makeConstraints { make in
            make.top.equalTo(propertiesContainer.snp.top)
            make.leading.trailing.equalTo(propertiesContainer)
        }

        propertiesStack.snp.makeConstraints { make in
            make.top.equalTo(propertiesHeader.snp.bottom).offset(12)
            make.leading.trailing.equalTo(propertiesContainer)
            make.bottom.equalTo(propertiesContainer.snp.bottom)
        }

        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(propertiesHeader.snp.bottom).offset(20)
            make.centerX.equalTo(propertiesContainer)
            make.bottom.equalTo(propertiesContainer.snp.bottom)
        }

        contentStack.addArrangedSubview(propertiesContainer)
    }

    private func bind() {
        viewModel.onDataChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.apply()
            }
        }
        apply()
    }

    private func apply() {
        let monthlySubtitle = subtitleText(income: viewModel.monthlyIncomeText, expenses: viewModel.monthlyExpensesText)
        let annualSubtitle = subtitleText(income: viewModel.annualIncomeText, expenses: viewModel.annualExpensesText)

        configureStatCard(
            monthlyCard,
            title: "Monthly Cash Flow",
            value: viewModel.netCashFlowText,
            subtitle: monthlySubtitle,
            positive: viewModel.isMonthlyPositive
        )
        configureStatCard(
            annualCard,
            title: "Annual Cash Flow",
            value: viewModel.annualNetText,
            subtitle: annualSubtitle,
            positive: viewModel.isAnnualNetPositive
        )

        propertiesStack.arrangedSubviews.forEach { view in
            propertiesStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        if viewModel.propertyItems.isEmpty {
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
            viewModel.propertyItems.forEach { item in
                let card = CashFlowPropertyCardView()
                card.configure(with: item) { [weak self] in
                    self?.showProperty(id: item.id)
                }
                propertiesStack.addArrangedSubview(card)
            }
        }
    }

    private func showProperty(id: String) {
        guard let property = viewModel.property(withId: id) else { return }
        coordinator?.showPropertyDetail(property)
    }

    private func configureStatCard(_ card: CardView, title: String, value: String, subtitle: String, positive: Bool) {
        card.titleLabel.text = title
        card.valueLabel.text = value
        card.subtitleLabel.text = subtitle
        if positive {
            card.valueLabel.textColor = .systemGreen
        } else {
            card.valueLabel.textColor = .systemRed
        }
    }

    private func subtitleText(income: String, expenses: String) -> String {
        return "Income: \(income)\nExpenses: \(expenses)"
    }
}
// 小工具 label：带内边距的标签，用来画 tag“IP / HOUSE / PPOR”
public final class PaddingLabel: UILabel {
    var horizontalPadding: CGFloat = 0
    var verticalPadding: CGFloat = 0

    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: verticalPadding,
                                  left: horizontalPadding,
                                  bottom: verticalPadding,
                                  right: horizontalPadding)
        super.drawText(in: rect.inset(by: insets))
    }

    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + horizontalPadding * 2,
            height: size.height + verticalPadding * 2
        )
    }
}
