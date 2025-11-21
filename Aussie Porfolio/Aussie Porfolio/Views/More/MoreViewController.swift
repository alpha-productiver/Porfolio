import UIKit

final class MoreViewController: UITableViewController {
    weak var coordinator: MainCoordinator?

    private enum Item: CaseIterable {
        case cash
        case otherAssets
        case liabilities

        var title: String {
            switch self {
            case .cash: return "Cash Accounts"
            case .otherAssets: return "Other Assets"
            case .liabilities: return "Liabilities"
            }
        }

        var detail: String {
            switch self {
            case .cash: return "View and edit your cash accounts"
            case .otherAssets: return "Manage shares, cash, and other assets"
            case .liabilities: return "Review your debts and repayments"
            }
        }

        var icon: String {
            switch self {
            case .cash: return "banknote"
            case .otherAssets: return "dollarsign.circle"
            case .liabilities: return "creditcard"
            }
        }
    }

    private let items = Item.allCases

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "More"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MoreCell")
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 0)
    }

    // MARK: - Table

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreCell", for: indexPath)
        let item = items[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        content.secondaryText = item.detail
        content.secondaryTextProperties.color = .secondaryLabel
        content.image = UIImage(systemName: item.icon)
        content.imageProperties.tintColor = .systemBlue
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        switch item {
        case .cash:
            coordinator?.showCash()
        case .otherAssets:
            coordinator?.showAssets()
        case .liabilities:
            coordinator?.showLiabilities()
        }
    }
}
