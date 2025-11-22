import UIKit

class LiabilitiesViewController: UIViewController {
    var viewModel: LiabilityViewModel!
    weak var coordinator: MainCoordinator?

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(LiabilityTableViewCell.self, forCellReuseIdentifier: "LiabilityCell")
        return table
    }()

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(systemName: "creditcard.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No liabilities added yet"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add Your First Liability", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(addLiabilityTapped), for: .touchUpInside)

        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 12),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        title = "Liabilities"
        view.backgroundColor = UIColor.systemGroupedBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addLiabilityTapped)
        )

        view.addSubview(tableView)
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onLiabilitiesChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
        updateUI()
    }

    private func updateUI() {
        tableView.reloadData()
        emptyStateView.isHidden = !viewModel.liabilities.isEmpty
        tableView.isHidden = viewModel.liabilities.isEmpty
    }

    @objc private func addLiabilityTapped() {
        coordinator?.showAddLiability()
    }
}

extension LiabilitiesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.liabilities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiabilityCell", for: indexPath) as! LiabilityTableViewCell
        let liability = viewModel.liabilities[indexPath.row]
        cell.configure(with: liability)
        return cell
    }
}

extension LiabilitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let liability = viewModel.liabilities[indexPath.row]
        coordinator?.showLiabilityDetail(liability)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { return }
            let liability = self.viewModel.liabilities[indexPath.row]

            let alert = UIAlertController(
                title: "Delete Liability",
                message: "Are you sure you want to delete \(liability.name)? This action cannot be undone.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completion(false)
            })

            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.viewModel.deleteLiability(liability)
                completion(true)
            })

            self.present(alert, animated: true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

class LiabilityTableViewCell: UITableViewCell {
    private let assetCardView = AssetCardView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        assetCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(assetCardView)

        NSLayoutConstraint.activate([
            assetCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            assetCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            assetCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            assetCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        accessoryType = .disclosureIndicator
    }

    func configure(with liability: Liability) {
        assetCardView.configure(with: liability)
    }
}