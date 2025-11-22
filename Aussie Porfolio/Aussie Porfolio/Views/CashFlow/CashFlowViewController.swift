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

    private let expensesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
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
        contentStack.addArrangedSubview(expensesLabel)

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
        configureStatCard(
            monthlyCard,
            title: "Monthly Cash Flow",
            value: viewModel.netCashFlowText,
            subtitle: "Income: \(viewModel.totalIncomeText)\nExpenses: \(viewModel.totalExpensesText)",
            positive: viewModel.isNetPositive
        )
        configureStatCard(
            annualCard,
            title: "Annual Cash Flow",
            value: viewModel.annualNetText,
            subtitle: "Income: \(viewModel.annualIncomeText)\nExpenses: \(viewModel.annualExpensesText)",
            positive: viewModel.isAnnualNetPositive
        )
        expensesLabel.text = viewModel.expensesBreakdownText

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
        // Keep existing styling; only adjust text content to avoid unexpected color changes.
    }
}

// MARK: - Property Card

private final class CashFlowPropertyCardView: UIView {
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

// 小工具 label：带内边距的标签，用来画 tag“IP / HOUSE / PPOR”
private final class PaddingLabel: UILabel {
    var horizontalPadding: CGFloat = 0
    var verticalPadding: CGFloat = 0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: verticalPadding,
                                  left: horizontalPadding,
                                  bottom: verticalPadding,
                                  right: horizontalPadding)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + horizontalPadding * 2,
            height: size.height + verticalPadding * 2
        )
    }
}
