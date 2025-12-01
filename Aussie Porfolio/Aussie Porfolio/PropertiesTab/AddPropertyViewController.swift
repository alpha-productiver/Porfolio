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
    private let rentalIncomeSection = RentalIncomeSectionView()

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
    private enum RepaymentFrequency: String, CaseIterable {
        case weekly = "Weekly"
        case fortnightly = "Fortnightly"
        case monthly = "Monthly"

        var paymentsPerYear: Double {
            switch self {
            case .weekly: return 52
            case .fortnightly: return 26
            case .monthly: return 12
            }
        }

        var menuTitle: String {
            "\(rawValue) (\(Int(paymentsPerYear))/yr)"
        }
    }
    private var selectedFrequency: RepaymentFrequency = .monthly
    private let frequencyButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Monthly (12/yr)", for: .normal)
        b.contentHorizontalAlignment = .left
        b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 8
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.separator.cgColor
        b.titleLabel?.font = .systemFont(ofSize: 15)
        b.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return b
    }()
    private let enterRepaymentManuallySwitch: UISwitch = {
        let s = UISwitch()
        s.onTintColor = .systemGreen
        return s
    }()
    private let assumedLoanTermYears: Double = 30
    private let interestOnlySwitch: UISwitch = {
        let s = UISwitch()
        s.onTintColor = .systemGreen
        return s
    }()
    private let customRepaymentField = LabeledField(title: "Custom Repayment Amount ($ per payment)",
                                                    placeholder: "Optional",
                                                    keyboard: .decimalPad)
    private let repaymentSummaryLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .systemBlue
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()
    private let loanNotesLabel: UILabel = {
        let l = UILabel()
        l.text = "Repayments auto-calculate from amount, rate, and frequency. Override with a custom payment if needed. P&L updates after save."
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()
    private let summaryHeader = FormSectionHeader("Monthly Summary")
    private let summaryLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()
    private let annualSummaryHeader = FormSectionHeader("Annual Summary")
    private let summaryCardBackground: UIColor = .secondarySystemGroupedBackground
    private let summaryCardCornerRadius: CGFloat = 10
    private let annualSummaryLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()
    private let monthlySummaryContainer = UIView()
    private let annualSummaryContainer = UIView()

    // Insurance
    private let insuranceSection = InsuranceSectionView()

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
        configureFrequencyMenu()
        updateCustomRepaymentTitle()
        addDoneToolbarToKeyboards()
        insuranceSection.layoutIfNeeded()
        rentalIncomeSection.onChange = { [weak self] in self?.updateFinancialSummary() }
        insuranceSection.onChange = { [weak self] in self?.updateFinancialSummary() }
        populateFieldsIfEditing()
        updateLoanNotes()
        updateRepaymentSummary()
        updateFinancialSummary()
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
        contentStack.addArrangedSubview(rentalIncomeSection)

        contentStack.addArrangedSubview(Divider())

        // Loan header
        contentStack.addArrangedSubview(loanHeader)
        contentStack.addArrangedSubview(loanHintLabel)

        // Loan container (always visible)
        loanContainer.axis = .vertical
        loanContainer.spacing = 14
        loanContainer.addArrangedSubview(loanAmountField)
        loanContainer.addArrangedSubview(interestRateField)

        let loanModeStack = UIStackView()
        loanModeStack.axis = .vertical
        loanModeStack.spacing = 8

        let interestOnlyRow = UIStackView()
        interestOnlyRow.axis = .horizontal
        interestOnlyRow.alignment = .center
        interestOnlyRow.spacing = 12
        let interestOnlyLabel = UILabel()
        interestOnlyLabel.text = "Interest-only"
        interestOnlyLabel.font = .systemFont(ofSize: 15, weight: .medium)
        interestOnlyLabel.textColor = .label

        let manualLabel = UILabel()
        manualLabel.text = "Enter repayment manually"
        manualLabel.font = .systemFont(ofSize: 15, weight: .medium)
        manualLabel.textColor = .label

        interestOnlyRow.addArrangedSubview(interestOnlyLabel)
        interestOnlyRow.addArrangedSubview(UIView())
        interestOnlyRow.addArrangedSubview(interestOnlySwitch)

        let manualRow = UIStackView(arrangedSubviews: [manualLabel, UIView(), enterRepaymentManuallySwitch])
        manualRow.axis = .horizontal
        manualRow.spacing = 8
        manualRow.alignment = .center

        loanModeStack.addArrangedSubview(interestOnlyRow)
        loanModeStack.addArrangedSubview(manualRow)
        loanContainer.addArrangedSubview(loanModeStack)
        enterRepaymentManuallySwitch.addTarget(self, action: #selector(toggleManualEntry(_:)), for: .valueChanged)
        interestOnlySwitch.addTarget(self, action: #selector(fieldDidChange), for: .valueChanged)

        let frequencyStack = UIStackView()
        frequencyStack.axis = .vertical
        frequencyStack.spacing = 6
        let frequencyLabel = UILabel()
        frequencyLabel.text = "Repayment Frequency"
        frequencyLabel.font = .systemFont(ofSize: 13, weight: .medium)
        frequencyLabel.textColor = .secondaryLabel
        frequencyStack.addArrangedSubview(frequencyLabel)
        frequencyStack.addArrangedSubview(frequencyButton)
        loanContainer.addArrangedSubview(frequencyStack)
        customRepaymentField.isHidden = true
        repaymentSummaryLabel.isHidden = true
        loanContainer.addArrangedSubview(customRepaymentField)
        loanContainer.addArrangedSubview(repaymentSummaryLabel)
        loanContainer.addArrangedSubview(loanNotesLabel)
        contentStack.addArrangedSubview(loanContainer)

        contentStack.addArrangedSubview(Divider())

        // Insurance section
        contentStack.addArrangedSubview(insuranceSection)

        contentStack.addArrangedSubview(Divider())
        contentStack.addArrangedSubview(summaryHeader)
        configureSummaryContainer(monthlySummaryContainer, label: summaryLabel)
        contentStack.addArrangedSubview(monthlySummaryContainer)
        contentStack.addArrangedSubview(annualSummaryHeader)
        configureSummaryContainer(annualSummaryContainer, label: annualSummaryLabel)
        contentStack.addArrangedSubview(annualSummaryContainer)
    }

    private func configureSummaryContainer(_ container: UIView, label: UILabel) {
        container.layer.cornerRadius = summaryCardCornerRadius
        container.layer.masksToBounds = true
        container.backgroundColor = summaryCardBackground
        container.translatesAutoresizingMaskIntoConstraints = false

        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])

        container.isHidden = true
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

    private func configureFrequencyMenu() {
        let actions = RepaymentFrequency.allCases.map { freq in
            UIAction(title: freq.rawValue, state: freq == selectedFrequency ? .on : .off) { [weak self] _ in
                guard let self else { return }
                selectedFrequency = freq
                let title = freq.menuTitle
                frequencyButton.setTitle(title, for: .normal)
                updateCustomRepaymentTitle()
                updateLoanNotes()
                updateRepaymentSummary()
            }
        }
        frequencyButton.menu = UIMenu(children: actions)
        frequencyButton.showsMenuAsPrimaryAction = true
    }

    private func updateCustomRepaymentTitle() {
        let lowercasedFreq = selectedFrequency.rawValue.lowercased()
        customRepaymentField.titleLabel.text = "Custom Repayment Amount ($ per \(lowercasedFreq) payment)"
    }

    @objc private func toggleManualEntry(_ sender: UISwitch) {
        customRepaymentField.isHidden = !sender.isOn
        updateLoanNotes()
        updateRepaymentSummary()
    }

    private func updateLoanNotes() {
        if enterRepaymentManuallySwitch.isOn {
            loanNotesLabel.text = "Enter repayments manually using frequency and amount. P&L will respect these values."
        } else {
            loanNotesLabel.text = "Repayments auto-calculate from amount, rate, and frequency (minimum interest). Override by enabling manual entry."
        }
    }

    private func parsedDouble(from field: LabeledField) -> Double? {
        let raw = field.textField.text?.replacingOccurrences(of: ",", with: "") ?? ""
        guard let value = Double(raw), value > 0 else { return nil }
        return value
    }

    private func currentPaymentsPerYear() -> Double {
        return selectedFrequency.paymentsPerYear
    }

    private struct RepaymentResult {
        let perPayment: Double
        let monthly: Double
        let yearly: Double
        let mode: String
    }

    private func computeRepayment() -> RepaymentResult? {
        guard let amount = parsedDouble(from: loanAmountField),
              let rate = parsedDouble(from: interestRateField) else {
            return nil
        }

        let paymentsPerYear = currentPaymentsPerYear()
        guard paymentsPerYear > 0 else { return nil }

        if interestOnlySwitch.isOn {
            let perPayment = amount * (rate / 100) / paymentsPerYear
            let monthly = perPayment * paymentsPerYear / 12
            return RepaymentResult(perPayment: perPayment,
                                   monthly: monthly,
                                   yearly: perPayment * paymentsPerYear,
                                   mode: "Interest-only")
        }

        if enterRepaymentManuallySwitch.isOn,
           let customPayment = parsedDouble(from: customRepaymentField),
           customPayment > 0 {
            let monthly = (customPayment * paymentsPerYear) / 12
            return RepaymentResult(perPayment: customPayment,
                                   monthly: monthly,
                                   yearly: monthly * 12,
                                   mode: "Manual")
        }

        let periodicRate = (rate / 100) / paymentsPerYear
        let n = assumedLoanTermYears * paymentsPerYear
        guard periodicRate > 0, n > 0 else { return nil }
        let perPayment = amount * periodicRate / (1 - pow(1 + periodicRate, -n))
        let monthly = perPayment * paymentsPerYear / 12
        return RepaymentResult(perPayment: perPayment,
                               monthly: monthly,
                               yearly: monthly * 12,
                               mode: "P&I")
    }

    private func updateRepaymentSummary() {
        guard let calc = computeRepayment() else {
            repaymentSummaryLabel.isHidden = true
            rentalIncomeSection.updateFinancialContext(purchasePrice: parsedDouble(from: purchaseField), monthlyLoanRepayment: nil)
            updateFinancialSummary()
            return
        }

        repaymentSummaryLabel.isHidden = false
        let perPaymentFrequency = selectedFrequency.rawValue.lowercased()
        repaymentSummaryLabel.text = "Est. repayment (\(calc.mode)): $\(Int(calc.perPayment).formattedWithSeparator()) per \(perPaymentFrequency) • $\(Int(calc.monthly).formattedWithSeparator()) / month • $\(Int(calc.yearly).formattedWithSeparator()) / year"
        rentalIncomeSection.updateFinancialContext(purchasePrice: parsedDouble(from: purchaseField), monthlyLoanRepayment: calc.monthly)
        updateFinancialSummary()
    }

    private func updateFinancialSummary() {
        let weeklyIncome = rentalIncomeSection.parsedWeeklyIncome()
        let monthlyIncome = weeklyIncome * 52 / 12

        let mgmtPercent = rentalIncomeSection.parsedManagementFeePercent()
        let mgmtMonthly = monthlyIncome * (mgmtPercent / 100)

        let expenses = rentalIncomeSection.parsedExpenses()
        let otherMonthly = expenses.isMonthly ? expenses.amount : expenses.amount / 12
        let insuranceMonthly = insuranceSection.currentMonthlyInsuranceEstimate()

        let loanMonthly = computeRepayment()?.monthly ?? 0
        let nonLoanExpenses = mgmtMonthly + otherMonthly + insuranceMonthly
        let totalCosts = nonLoanExpenses + loanMonthly
        let net = monthlyIncome - totalCosts

        guard monthlyIncome > 0 || totalCosts > 0 else {
            summaryLabel.isHidden = true
            summaryLabel.text = nil
            monthlySummaryContainer.isHidden = true
            annualSummaryLabel.isHidden = true
            annualSummaryLabel.text = nil
            annualSummaryContainer.isHidden = true
            return
        }

        summaryLabel.isHidden = false
        monthlySummaryContainer.isHidden = false
        let incomeText = Int(monthlyIncome).formattedWithSeparator()
        let loanText = Int(loanMonthly).formattedWithSeparator()
        let expenseText = Int(nonLoanExpenses).formattedWithSeparator()
        let netText = Int(abs(net)).formattedWithSeparator()
        let netPrefix = net < 0 ? "-$" : "$"
        let netColor: UIColor = net >= 0 ? .systemGreen : .systemRed

        let text = NSMutableAttributedString(
            string: "Estimated monthly cash flow: ",
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        )
        text.append(NSAttributedString(
            string: "\(netPrefix)\(netText)",
            attributes: [.foregroundColor: netColor]
        ))
        text.append(NSAttributedString(
            string: "\nIncome: $\(incomeText) • Loan: $\(loanText) • Expenses: $\(expenseText)",
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        ))
        summaryLabel.attributedText = text

        let annualIncome = monthlyIncome * 12
        let annualLoan = loanMonthly * 12
        let annualExpenses = nonLoanExpenses * 12
        let annualNet = annualIncome - annualLoan - annualExpenses
        let annualNetPrefix = annualNet < 0 ? "-$" : "$"
        let annualNetColor: UIColor = annualNet >= 0 ? .systemGreen : .systemRed

        annualSummaryLabel.isHidden = false
        annualSummaryContainer.isHidden = false
        let annualText = NSMutableAttributedString(
            string: "Estimated annual cash flow: ",
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        )
        annualText.append(NSAttributedString(
            string: "\(annualNetPrefix)\(Int(abs(annualNet)).formattedWithSeparator())",
            attributes: [.foregroundColor: annualNetColor]
        ))
        annualText.append(NSAttributedString(
            string: "\nIncome: $\(Int(annualIncome).formattedWithSeparator()) • Loan: $\(Int(annualLoan).formattedWithSeparator()) • Expenses: $\(Int(annualExpenses).formattedWithSeparator())",
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        ))
        annualSummaryLabel.attributedText = annualText
    }

    // Add "Done" toolbar for number pads
    private func addDoneToolbarToKeyboards() {
        ([purchaseField.textField,
          currentValueField.textField,
          loanAmountField.textField,
          interestRateField.textField,
          customRepaymentField.textField,
          rentalIncomeSection.weeklyIncomeField.textField] + insuranceSection.numericTextFields).forEach { tf in
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
        rentalIncomeSection.weeklyIncomeField.textField.delegate = self
        rentalIncomeSection.weeklyIncomeField.textField.addTarget(self, action: #selector(currencyFieldDidChange(_:)), for: .editingChanged)
        loanAmountField.textField.delegate = self
        loanAmountField.textField.addTarget(self, action: #selector(currencyFieldDidChange(_:)), for: .editingChanged)
        interestRateField.textField.delegate = self
        interestRateField.textField.addTarget(self, action: #selector(fieldDidChange), for: .editingChanged)
        customRepaymentField.textField.delegate = self
        customRepaymentField.textField.addTarget(self, action: #selector(currencyFieldDidChange(_:)), for: .editingChanged)
    }

    @objc private func currencyFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }

        // Remove commas and format with commas
        let numbersOnly = text.replacingOccurrences(of: ",", with: "")
        if let number = Int(numbersOnly) {
            textField.text = number.formattedWithSeparator()
        }
        updateRepaymentSummary()
    }

    @objc private func fieldDidChange() {
        updateRepaymentSummary()
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
        rentalIncomeSection.setValues(
            weeklyIncome: property.rentalIncome,
            managementFeePercent: property.managementFeePercent,
            expensesAmount: property.estimatedExpensesAmount,
            expensesFrequencyMonthly: property.expensesAreMonthly
        )

        if let loan = property.loan {
            loanAmountField.textField.text = Int(loan.amount).formattedWithSeparator()
            interestRateField.textField.text = "\(loan.interestRate)"
            interestOnlySwitch.isOn = loan.loanType.lowercased() == "interest-only"

            let freqPerYear = loan.repaymentFrequencyPerYear > 0 ? loan.repaymentFrequencyPerYear : 12
            switch freqPerYear {
            case 52: selectedFrequency = .weekly
            case 26: selectedFrequency = .fortnightly
            case 12: selectedFrequency = .monthly
            default: selectedFrequency = .monthly
            }
            frequencyButton.setTitle(selectedFrequency.menuTitle, for: .normal)
            updateCustomRepaymentTitle()
            configureFrequencyMenu()

            if loan.usesManualRepayment {
                enterRepaymentManuallySwitch.isOn = true
                customRepaymentField.isHidden = false
                if loan.customPaymentPerPeriod > 0 {
                    customRepaymentField.textField.text = String(format: "%.0f", loan.customPaymentPerPeriod)
                }
            }
        }
        updateLoanNotes()
        updateRepaymentSummary()

        insuranceSection.populate(with: property.insurance)
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
        let rentalIncome = rentalIncomeSection.parsedWeeklyIncome()
        let managementFeePercent = rentalIncomeSection.parsedManagementFeePercent()
        let expensesParsed = rentalIncomeSection.parsedExpenses()

        // Validate loan if amount is provided
        var loanData: (amount: Double, interestRate: Double, loanType: String, monthlyRepayment: Double, frequencyPerYear: Int, customPerPeriod: Double, usesManual: Bool)? = nil
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

                let amount = NSDecimalNumber(decimal: amt).doubleValue
                let rate = NSDecimalNumber(decimal: ir).doubleValue

                let calc = computeRepayment()
                let paymentsPerYear = currentPaymentsPerYear()
                let customPerPeriod = enterRepaymentManuallySwitch.isOn ? (parsedDouble(from: customRepaymentField) ?? 0) : 0
                let loanType = interestOnlySwitch.isOn ? "interest-only" : "principal-and-interest"

                loanData = (amount, rate, loanType, calc?.monthly ?? 0, Int(paymentsPerYear), customPerPeriod, enterRepaymentManuallySwitch.isOn)
            }
        }

        let insuranceResult = insuranceSection.insuranceData(onValidationError: showAlert)
        var insuranceData: (
            buildingProvider: String, buildingFrequency: String, buildingAmount: Double, buildingRenewalDate: Date?,
            landlordProvider: String, landlordFrequency: String, landlordAmount: Double, landlordRenewalDate: Date?,
            sameProvider: Bool
        )? = nil

        switch insuranceResult {
        case .invalid:
            return
        case .none:
            insuranceData = nil
        case .valid(let data):
            insuranceData = (
                buildingProvider: data.buildingProvider,
                buildingFrequency: data.buildingFrequency,
                buildingAmount: data.buildingAmount,
                buildingRenewalDate: data.buildingRenewalDate,
                landlordProvider: data.landlordProvider,
                landlordFrequency: data.landlordFrequency,
                landlordAmount: data.landlordAmount,
                landlordRenewalDate: data.landlordRenewalDate,
                sameProvider: data.sameProvider
            )
        }

        // Handle edit vs add
        if let existingProperty = propertyToEdit {
            // Update existing property inside write transaction
            viewModel.updateProperty(existingProperty,
                                    address: addr,
                                    state: state.rawValue,
                                    purchasePrice: purchaseValue,
                                    currentValue: currentValue,
                                    rentalIncome: rentalIncome,
                                    managementFeePercent: managementFeePercent,
                                    estimatedExpensesAmount: expensesParsed.amount,
                                    expensesAreMonthly: false,
                                    loanData: loanData,
                                    insuranceData: insuranceData)
        } else {
            // Create new property
            let property = Property()
            property.name = addr
            property.address = addr
            property.state = state.rawValue
            property.purchasePrice = purchaseValue
            property.currentValue = currentValue
            property.rentalIncome = rentalIncome
            property.managementFeePercent = managementFeePercent
            property.estimatedExpensesAmount = expensesParsed.amount
            property.expensesAreMonthly = false

            if let loan = loanData {
                let propertyLoan = PropertyLoan()
                propertyLoan.amount = loan.amount
                propertyLoan.interestRate = loan.interestRate
                propertyLoan.loanType = loan.loanType
                propertyLoan.monthlyRepayment = loan.monthlyRepayment
                propertyLoan.repaymentFrequencyPerYear = loan.frequencyPerYear
                propertyLoan.customPaymentPerPeriod = loan.customPerPeriod
                propertyLoan.usesManualRepayment = loan.usesManual
                property.loan = propertyLoan
            }

            if let insurance = insuranceData {
                let propertyInsurance = PropertyInsurance()
                propertyInsurance.buildingProvider = insurance.buildingProvider
                propertyInsurance.buildingFrequency = insurance.buildingFrequency
                propertyInsurance.buildingAmount = insurance.buildingAmount
                propertyInsurance.buildingRenewalDate = insurance.buildingRenewalDate
                propertyInsurance.landlordProvider = insurance.landlordProvider
                propertyInsurance.landlordFrequency = insurance.landlordFrequency
                propertyInsurance.landlordAmount = insurance.landlordAmount
                propertyInsurance.landlordRenewalDate = insurance.landlordRenewalDate
                propertyInsurance.sameProvider = insurance.sameProvider
                property.insurance = propertyInsurance
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
