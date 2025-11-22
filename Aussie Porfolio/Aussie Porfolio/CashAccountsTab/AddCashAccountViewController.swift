import UIKit

final class AddCashAccountViewController: UIViewController {

    weak var coordinator: MainCoordinator?
    private let viewModel: CashAccountViewModel
    private let accountToEdit: CashAccount?

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // Account details
    private let nameField = LabeledField(title: "Account Name",
                                         placeholder: "e.g., Savings Account, Emergency Fund")
    private let institutionField = LabeledField(title: "Institution",
                                               placeholder: "e.g., Commonwealth Bank")

    // Financial details
    private let balanceField = LabeledField(title: "Current Balance ($)",
                                           placeholder: "10,000",
                                           keyboard: .numberPad)
    private let interestRateField = LabeledField(title: "Interest Rate (%) - Optional",
                                                placeholder: "2.5",
                                                keyboard: .decimalPad)
    private let notesField = LabeledField(title: "Notes (optional)",
                                         placeholder: "Additional information")

    // MARK: - Init
    init(viewModel: CashAccountViewModel, accountToEdit: CashAccount? = nil) {
        self.viewModel = viewModel
        self.accountToEdit = accountToEdit
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = accountToEdit == nil ? "Add Cash Account" : "Edit Cash Account"
        view.backgroundColor = .systemGroupedBackground
        setupNav()
        buildForm()
        addDoneToolbarToKeyboards()
        populateFieldsIfEditing()
    }

    // MARK: - Nav
    private func setupNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
    }

    // MARK: - Form layout
    private func buildForm() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 14
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])

        // Account Details
        contentStack.addArrangedSubview(FormSectionHeader("Account Details"))
        contentStack.addArrangedSubview(nameField)
        contentStack.addArrangedSubview(institutionField)

        contentStack.addArrangedSubview(Divider())

        // Financial Details
        contentStack.addArrangedSubview(FormSectionHeader("Financial Details"))
        contentStack.addArrangedSubview(balanceField)
        contentStack.addArrangedSubview(interestRateField)

        contentStack.addArrangedSubview(Divider())

        // Notes
        contentStack.addArrangedSubview(FormSectionHeader("Additional Information"))
        contentStack.addArrangedSubview(notesField)
    }

    // Add "Done" toolbar for number pads
    private func addDoneToolbarToKeyboards() {
        [balanceField.textField,
         interestRateField.textField].forEach { tf in
            let tb = UIToolbar()
            tb.sizeToFit()
            let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: tf, action: #selector(UIView.endEditing(_:)))
            tb.items = [flex, done]
            tf.inputAccessoryView = tb
        }

        // Set delegate for currency fields to add comma formatting
        balanceField.textField.delegate = self
        balanceField.textField.addTarget(self, action: #selector(currencyFieldDidChange(_:)), for: .editingChanged)
    }

    @objc private func currencyFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }

        // Remove commas and format with commas
        let numbersOnly = text.replacingOccurrences(of: ",", with: "")
        if let number = Int(numbersOnly) {
            textField.text = number.formattedWithSeparator()
        }
    }

    private func populateFieldsIfEditing() {
        guard let account = accountToEdit else { return }

        nameField.textField.text = account.name
        institutionField.textField.text = account.institution
        balanceField.textField.text = Int(account.balance).formattedWithSeparator()
        interestRateField.textField.text = account.interestRate > 0 ? "\(account.interestRate)" : ""
        notesField.textField.text = account.notes
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        // Basic validation
        guard let name = nameField.textField.text, !name.isEmpty else {
            showAlert("Please enter an account name."); return
        }
        guard let institution = institutionField.textField.text, !institution.isEmpty else {
            showAlert("Please enter an institution."); return
        }

        // Strip commas before parsing
        let balanceText = balanceField.textField.text?.replacingOccurrences(of: ",", with: "") ?? ""
        guard let balance = Decimal(string: balanceText), balance >= 0 else {
            showAlert("Please enter a valid balance."); return
        }

        let balanceDouble = NSDecimalNumber(decimal: balance).doubleValue

        let interestRate: Double
        if let rateText = interestRateField.textField.text, !rateText.isEmpty,
           let rate = Double(rateText) {
            interestRate = rate
        } else {
            interestRate = 0
        }

        let notes = notesField.textField.text ?? ""

        // Handle edit vs add
        if let existingAccount = accountToEdit {
            viewModel.updateCashAccount(existingAccount,
                                       name: name,
                                       accountType: "savings",
                                       balance: balanceDouble,
                                       interestRate: interestRate,
                                       institution: institution,
                                       notes: notes)
        } else {
            let account = CashAccount()
            account.name = name
            account.accountType = "savings"
            account.balance = balanceDouble
            account.interestRate = interestRate
            account.institution = institution
            account.notes = notes

            viewModel.addCashAccount(account)
        }

        dismiss(animated: true)
    }

    private func showAlert(_ msg: String) {
        let ac = UIAlertController(title: "Missing info", message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension AddCashAccountViewController: UITextFieldDelegate {
    // Allow editing to proceed as normal
}
