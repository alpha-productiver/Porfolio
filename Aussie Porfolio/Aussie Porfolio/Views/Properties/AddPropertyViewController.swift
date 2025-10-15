import UIKit

final class AddPropertyViewController: UIViewController {

    weak var coordinator: MainCoordinator?
    private let viewModel: PropertyViewModel
    private let propertyToEdit: Property?

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // Property details
    private let addressField = LabeledField(title: "Address",
                                            placeholder: "123 Smith St, Melbourne")
    private lazy var stateButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("NSW", for: .normal)
        b.contentHorizontalAlignment = .center
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 8
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.separator.cgColor
        b.titleLabel?.font = .systemFont(ofSize: 15)
        b.heightAnchor.constraint(equalToConstant: 40).isActive = true
        b.widthAnchor.constraint(equalToConstant: 70).isActive = true
        return b
    }()
    private var selectedState: StateAU = .NSW

    // Financial details
    private let purchaseField = LabeledField(title: "Purchase Value ($)",
                                             placeholder: "750,000",
                                             keyboard: .numberPad)
    private let currentValueField = LabeledField(title: "Current Value ($)",
                                                 placeholder: "Leave empty to use purchase price",
                                                 keyboard: .numberPad)

    // Loan
    private let loanHeader = FormSectionHeader("Loan Details")
    private let loanHintLabel: UILabel = {
        let l = UILabel()
        l.text = "If this property is mortgage-free, leave the loan amount empty"
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()
    private let loanContainer = UIStackView()
    private let loanAmountField = LabeledField(title: "Loan Amount ($)",
                                               placeholder: "Leave empty if mortgage-free",
                                               keyboard: .numberPad)
    private let interestRateField = LabeledField(title: "Interest Rate (%)",
                                                 placeholder: "6.0",
                                                 keyboard: .decimalPad)

    // MARK: - Init
    init(viewModel: PropertyViewModel, propertyToEdit: Property? = nil) {
        self.viewModel = viewModel
        self.propertyToEdit = propertyToEdit
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = propertyToEdit == nil ? "Add Property" : "Edit Property"
        view.backgroundColor = .systemGroupedBackground
        setupNav()
        buildForm()
        configureStateMenu()
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

        // Property Details
        contentStack.addArrangedSubview(FormSectionHeader("Property Details"))

        // Address and State on same line
        let stateStack = UIStackView()
        stateStack.axis = .vertical
        stateStack.spacing = 6
        let stateLabel = UILabel()
        stateLabel.text = "State"
        stateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        stateLabel.textColor = .secondaryLabel
        stateStack.addArrangedSubview(stateLabel)
        stateStack.addArrangedSubview(stateButton)

        let addressStateRow = UIStackView(arrangedSubviews: [addressField, stateStack])
        addressStateRow.axis = .horizontal
        addressStateRow.spacing = 12
        addressStateRow.alignment = .fill
        addressStateRow.distribution = .fill
        contentStack.addArrangedSubview(addressStateRow)

        contentStack.addArrangedSubview(Divider())

        // Financial Details
        contentStack.addArrangedSubview(FormSectionHeader("Financial Details"))
        contentStack.addArrangedSubview(purchaseField)
        contentStack.addArrangedSubview(currentValueField)

        contentStack.addArrangedSubview(Divider())

        // Loan header
        contentStack.addArrangedSubview(loanHeader)
        contentStack.addArrangedSubview(loanHintLabel)

        // Loan container (always visible)
        loanContainer.axis = .vertical
        loanContainer.spacing = 14
        loanContainer.addArrangedSubview(loanAmountField)
        loanContainer.addArrangedSubview(interestRateField)
        contentStack.addArrangedSubview(loanContainer)
    }

    private func configureStateMenu() {
        var actions: [UIAction] = []
        for s in StateAU.allCases {
            actions.append(UIAction(title: s.rawValue) { [weak self] _ in
                self?.stateButton.setTitle(s.rawValue, for: .normal)
                self?.selectedState = s
            })
        }
        stateButton.menu = UIMenu(children: actions)
        stateButton.showsMenuAsPrimaryAction = true
    }

    // Add "Done" toolbar for number pads
    private func addDoneToolbarToKeyboards() {
        [purchaseField.textField,
         currentValueField.textField,
         loanAmountField.textField,
         interestRateField.textField].forEach { tf in
            let tb = UIToolbar()
            tb.sizeToFit()
            let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: tf, action: #selector(UIView.endEditing(_:)))
            tb.items = [flex, done]
            tf.inputAccessoryView = tb
        }

        // Set delegate for currency fields to add comma formatting
        purchaseField.textField.delegate = self
        purchaseField.textField.addTarget(self, action: #selector(currencyFieldDidChange(_:)), for: .editingChanged)
        currentValueField.textField.delegate = self
        currentValueField.textField.addTarget(self, action: #selector(currencyFieldDidChange(_:)), for: .editingChanged)
        loanAmountField.textField.delegate = self
        loanAmountField.textField.addTarget(self, action: #selector(currencyFieldDidChange(_:)), for: .editingChanged)
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
        guard let property = propertyToEdit else { return }

        addressField.textField.text = property.address

        if let state = StateAU(rawValue: property.state) {
            selectedState = state
            stateButton.setTitle(state.rawValue, for: .normal)
        }

        purchaseField.textField.text = Int(property.purchasePrice).formattedWithSeparator()
        currentValueField.textField.text = Int(property.currentValue).formattedWithSeparator()

        if let loan = property.loan {
            loanAmountField.textField.text = Int(loan.amount).formattedWithSeparator()
            interestRateField.textField.text = "\(loan.interestRate)"
        }
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        // Basic validation
        guard let addr = addressField.textField.text, !addr.isEmpty else {
            showAlert("Please enter an address."); return
        }
        let state = selectedState

        // Strip commas before parsing
        let purchaseText = purchaseField.textField.text?.replacingOccurrences(of: ",", with: "") ?? ""
        guard let purchase = Decimal(string: purchaseText), purchase > 0 else {
            showAlert("Please enter a valid purchase value."); return
        }

        let purchaseValue = NSDecimalNumber(decimal: purchase).doubleValue
        let currentValue: Double
        let currentValueText = currentValueField.textField.text?.replacingOccurrences(of: ",", with: "") ?? ""
        if let cv = Decimal(string: currentValueText), cv > 0 {
            currentValue = NSDecimalNumber(decimal: cv).doubleValue
        } else {
            currentValue = purchaseValue
        }

        // Validate loan if amount is provided
        var loanData: (amount: Double, interestRate: Double)? = nil
        if let loanAmountText = loanAmountField.textField.text,
           !loanAmountText.isEmpty {
            let loanAmountClean = loanAmountText.replacingOccurrences(of: ",", with: "")
            if let amt = Decimal(string: loanAmountClean), amt > 0 {

                // If loan amount is entered, interest rate is required
                guard let interestRateText = interestRateField.textField.text,
                      !interestRateText.isEmpty,
                      let ir = Decimal(string: interestRateText),
                      ir > 0 else {
                    showAlert("Please enter an interest rate for the loan."); return
                }

                loanData = (NSDecimalNumber(decimal: amt).doubleValue, NSDecimalNumber(decimal: ir).doubleValue)
            }
        }

        // Handle edit vs add
        if let existingProperty = propertyToEdit {
            // Update existing property inside write transaction
            viewModel.updateProperty(existingProperty,
                                    address: addr,
                                    state: state.rawValue,
                                    purchasePrice: purchaseValue,
                                    currentValue: currentValue,
                                    loanData: loanData)
        } else {
            // Create new property
            let property = Property()
            property.name = addr
            property.address = addr
            property.state = state.rawValue
            property.purchasePrice = purchaseValue
            property.currentValue = currentValue

            if let loan = loanData {
                let propertyLoan = PropertyLoan()
                propertyLoan.amount = loan.amount
                propertyLoan.interestRate = loan.interestRate
                propertyLoan.loanType = "variable"
                property.loan = propertyLoan
            }

            viewModel.addProperty(property)
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

extension AddPropertyViewController: UITextFieldDelegate {
    // Allow editing to proceed as normal
}
