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

    private let summaryCard = CashFlowSummaryCardView()

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

        contentStack.addArrangedSubview(summaryCard)

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
        summaryCard.configure(
            incomeText: viewModel.totalIncomeText,
            expensesText: viewModel.totalExpensesText,
            netText: viewModel.netCashFlowText,
            isPositive: viewModel.isNetPositive
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
                card.configure(with: item)
                propertiesStack.addArrangedSubview(card)
            }
        }
    }
}

// MARK: - Summary Card

private final class CashFlowSummaryCardView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "This Month"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let incomeMetric = CashFlowMetricView(title: "Income", icon: "arrow.up.right")
    private let expenseMetric = CashFlowMetricView(title: "Expenses", icon: "arrow.down.right")
    private let netLabel = UILabel()

    private let sparkline = CashFlowSparklineView()

    init() {
        super.init(frame: .zero)
        layer.cornerRadius = 20
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowRadius = 16
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build() {
        let netTitle = UILabel()
        netTitle.text = "Net"
        netTitle.font = UIFont.preferredFont(forTextStyle: .caption1)
        netTitle.textColor = .secondaryLabel

        netLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        netLabel.textColor = .label

        let metricsStack = UIStackView(arrangedSubviews: [incomeMetric, expenseMetric, verticalNetStack(title: netTitle)])
        metricsStack.axis = .horizontal
        metricsStack.spacing = 12
        metricsStack.distribution = .fillEqually

        let divider = UIView()
        divider.backgroundColor = .systemGray4
        divider.snp.makeConstraints { $0.height.equalTo(1) }

        addSubview(titleLabel)
        addSubview(metricsStack)
        addSubview(divider)
        addSubview(sparkline)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        metricsStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        divider.snp.makeConstraints { make in
            make.top.equalTo(metricsStack.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        sparkline.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(90)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    private func verticalNetStack(title: UILabel) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [title, netLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }

    func configure(incomeText: String, expensesText: String, netText: String, isPositive: Bool) {
        incomeMetric.configure(value: incomeText, isPositive: true)
        expenseMetric.configure(value: expensesText, isPositive: false)
        netLabel.text = netText
        netLabel.textColor = isPositive ? .systemGreen : .systemRed
        sparkline.isPositive = isPositive
    }
}

private final class CashFlowMetricView: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let iconView = UIImageView()

    init(title: String, icon: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .secondaryLabel
        valueLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        valueLabel.textColor = .label
        titleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = .secondaryLabel
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4

        addSubview(iconView)
        addSubview(stack)

        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.height.equalTo(18)
        }

        stack.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(6)
            make.centerY.equalTo(iconView.snp.centerY)
            make.trailing.equalToSuperview()
        }
    }

    func configure(value: String, isPositive: Bool) {
        valueLabel.text = value
        valueLabel.textColor = isPositive ? .systemGreen : .systemRed
        iconView.tintColor = isPositive ? .systemGreen : .systemRed
    }
}

private final class CashFlowSparklineView: UIView {
    var isPositive: Bool = true { didSet { setNeedsDisplay() } }
    private let points: [CGFloat] = [0.2, 0.55, 0.35, 0.7, 0.5, 0.8]

    override func draw(_ rect: CGRect) {
        guard points.count > 1 else { return }
        let path = UIBezierPath()
        let stepX = rect.width / CGFloat(points.count - 1)

        for (index, point) in points.enumerated() {
            let x = CGFloat(index) * stepX
            let y = rect.height * (1 - point)
            let currentPoint = CGPoint(x: x, y: y)
            if index == 0 {
                path.move(to: currentPoint)
            } else {
                path.addLine(to: currentPoint)
            }
        }

        (isPositive ? UIColor.systemGreen : UIColor.systemRed).setStroke()
        path.lineWidth = 2
        path.stroke()

        for (index, point) in points.enumerated() {
            let x = CGFloat(index) * stepX
            let y = rect.height * (1 - point)
            let dotRect = CGRect(x: x - 3, y: y - 3, width: 6, height: 6)
            let dotPath = UIBezierPath(ovalIn: dotRect)
            (isPositive ? UIColor.systemGreen : UIColor.systemRed).setFill()
            dotPath.fill()
        }
    }
}

// MARK: - Property Card

private final class CashFlowPropertyCardView: UIView {
    private let iconContainer = UIView()
    private let iconView = UIImageView()
    private let nameLabel = UILabel()
    private let tagLabel = UILabel()
    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
    private let incomeLabel = UILabel()
    private let expenseLabel = UILabel()
    private let netLabel = UILabel()
    private let nextPaymentLabel = UILabel()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 18
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 10

        iconContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 22

        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .label

        tagLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        tagLabel.textColor = .systemGreen
        tagLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        tagLabel.layer.cornerRadius = 10
        tagLabel.clipsToBounds = true
        tagLabel.textAlignment = .center

        chevronView.tintColor = .tertiaryLabel
        chevronView.contentMode = .scaleAspectFit

        incomeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        incomeLabel.textColor = .systemGreen

        expenseLabel.font = .systemFont(ofSize: 14, weight: .medium)
        expenseLabel.textColor = .systemRed

        netLabel.font = .systemFont(ofSize: 15, weight: .semibold)

        nextPaymentLabel.font = .systemFont(ofSize: 13, weight: .regular)
        nextPaymentLabel.textColor = .secondaryLabel
        nextPaymentLabel.numberOfLines = 0

        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 12

        let titleStack = UIStackView(arrangedSubviews: [nameLabel, tagLabel])
        titleStack.axis = .horizontal
        titleStack.spacing = 8

        let textAndChevron = UIStackView(arrangedSubviews: [titleStack, chevronView])
        textAndChevron.axis = .horizontal
        textAndChevron.alignment = .center
        textAndChevron.spacing = 8

        let incomesStack = UIStackView(arrangedSubviews: [incomeLabel, expenseLabel])
        incomesStack.axis = .horizontal
        incomesStack.spacing = 12
        incomesStack.alignment = .leading

        let netStack = UIStackView(arrangedSubviews: [netLabel, UIView()])
        netStack.axis = .horizontal
        netStack.alignment = .leading

        let verticalStack = UIStackView(arrangedSubviews: [headerStack, incomesStack, divider(), netStack, nextPaymentLabel])
        verticalStack.axis = .vertical
        verticalStack.spacing = 8

        iconContainer.addSubview(iconView)
        headerStack.addArrangedSubview(iconContainer)
        headerStack.addArrangedSubview(textAndChevron)

        addSubview(verticalStack)

        iconContainer.snp.makeConstraints { make in
            make.width.height.equalTo(44)
        }

        iconView.snp.makeConstraints { make in
            make.center.equalTo(iconContainer)
            make.width.height.equalTo(22)
        }

        verticalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }

        tagLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }

        chevronView.snp.makeConstraints { make in
            make.width.equalTo(10)
        }
    }

    func configure(with item: CashFlowPropertyItem) {
        iconView.image = UIImage(systemName: item.iconSystemName)
        iconView.tintColor = .systemBlue
        nameLabel.text = item.name
        tagLabel.text = " \(item.tag) "
        incomeLabel.text = "Income: \(item.incomeText)"
        expenseLabel.text = "Expenses: \(item.expensesText)"
        netLabel.text = "Net: \(item.netText)"
        netLabel.textColor = item.netIsPositive ? .systemGreen : .systemRed
        nextPaymentLabel.text = item.nextPaymentText
    }

    private func divider() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.snp.makeConstraints { $0.height.equalTo(1) }
        return view
    }
}
