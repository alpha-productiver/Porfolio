import UIKit

final class AddPropertyViewController: UIViewController {

    weak var coordinator: MainCoordinator?
    private let viewModel: PropertyViewModel
    private let propertyToEdit: Property?

    // MARK: - Constants
    private static let insuranceProviders = [
        "AAMI",
        "AJG Australia",
        "Allianz",
        "Aon",
        "Apia",
        "Australian Landlord Insurance",
        "Australian Unity",
        "Budget Direct",
        "CGU Insurance",
        "CHU",
        "Coles Insurance",
        "EBM RentCover",
        "GIO",
        "ING",
        "NRMA Insurance",
        "QBE",
        "Qantas Insurance",
        "Suncorp Insurance",
        "Terri Scheer",
        "Youi"
    ]

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
        case custom = "Custom"

        var paymentsPerYear: Double {
            switch self {
            case .weekly: return 52
            case .fortnightly: return 26
            case .monthly: return 12
            case .custom: return 0
            }
        }
    }
    private var selectedFrequency: RepaymentFrequency = .monthly
    private var frequencyPaymentsPerYear: Double = 12
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
    private let customPaymentsField = LabeledField(title: "Custom Payments per Year",
                                                   placeholder: "e.g. 24",
                                                   keyboard: .numberPad)
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
        l.text = "Repayments auto-calculate from amount, rate, and frequency. Override with a custom payment or custom frequency if needed. P&L updates after save."
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()

    // Insurance
    private let insuranceHeader = FormSectionHeader("Insurance Details (Optional)")
    private let insuranceHintLabel: UILabel = {
        let l = UILabel()
        l.text = "Add property insurance information if applicable"
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()
    private let insuranceContainer = UIStackView()

    // Same provider checkbox
    private let sameProviderCheckbox: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "square"), for: .normal)
        b.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        b.contentHorizontalAlignment = .center
        b.tintColor = .systemBlue
        b.widthAnchor.constraint(equalToConstant: 24).isActive = true
        b.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return b
    }()
    private let sameProviderLabel: UILabel = {
        let l = UILabel()
        l.text = "Both insurances have the same provider"
        l.font = .systemFont(ofSize: 15)
        l.textColor = .label
        return l
    }()

    // Combined Insurance (when same provider is checked)
    private let combinedInsuranceHeader = FormSectionHeader("Building & Landlord Insurance")
    private lazy var combinedProviderButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Select Provider", for: .normal)
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
    private var combinedSelectedProvider = "Select Provider"
    private let combinedCustomProviderField = LabeledField(title: "Custom Provider",
                                                           placeholder: "Enter provider name")
    private lazy var combinedFrequencyButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Monthly", for: .normal)
        b.contentHorizontalAlignment = .center
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 8
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.separator.cgColor
        b.titleLabel?.font = .systemFont(ofSize: 15)
        b.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return b
    }()
    private var combinedSelectedFrequency = "Monthly"
    private let combinedAmountField = LabeledField(title: "Repayment Amount ($)",
                                                   placeholder: "e.g. 150",
                                                   keyboard: .decimalPad)
    private let combinedRenewalDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()
    private let combinedYearlyLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .systemBlue
        l.numberOfLines = 0
        return l
    }()
    private let combinedContainer = UIStackView()

    // Building Insurance
    private let buildingContainer = UIStackView()
    private let buildingInsuranceHeader = FormSectionHeader("Building Insurance")
    private lazy var buildingProviderButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Select Provider", for: .normal)
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
    private var buildingSelectedProvider = "Select Provider"
    private let buildingCustomProviderField = LabeledField(title: "Custom Provider",
                                                           placeholder: "Enter provider name")
    private lazy var buildingFrequencyButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Monthly", for: .normal)
        b.contentHorizontalAlignment = .center
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 8
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.separator.cgColor
        b.titleLabel?.font = .systemFont(ofSize: 15)
        b.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return b
    }()
    private var buildingSelectedFrequency = "Monthly"
    private let buildingAmountField = LabeledField(title: "Repayment Amount ($)",
                                                   placeholder: "e.g. 150",
                                                   keyboard: .decimalPad)
    private let buildingRenewalDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()
    private let buildingYearlyLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .systemBlue
        l.numberOfLines = 0
        return l
    }()

    // Landlord Insurance
    private let landlordContainer = UIStackView()
    private let landlordInsuranceHeader = FormSectionHeader("Landlord Insurance")
    private lazy var landlordProviderButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Select Provider", for: .normal)
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
    private var landlordSelectedProvider = "Select Provider"
    private let landlordCustomProviderField = LabeledField(title: "Custom Provider",
                                                           placeholder: "Enter provider name")
    private lazy var landlordFrequencyButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Monthly", for: .normal)
        b.contentHorizontalAlignment = .center
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 8
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.separator.cgColor
        b.titleLabel?.font = .systemFont(ofSize: 15)
        b.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return b
    }()
    private var landlordSelectedFrequency = "Monthly"
    private let landlordAmountField = LabeledField(title: "Repayment Amount ($)",
                                                   placeholder: "e.g. 150",
                                                   keyboard: .decimalPad)
    private let landlordRenewalDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()
    private let landlordYearlyLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .systemBlue
        l.numberOfLines = 0
        return l
    }()

    private let totalInsuranceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = .systemGreen
        l.numberOfLines = 0
        return l
    }()

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
        configureCombinedProviderMenu()
        configureBuildingProviderMenu()
        configureLandlordProviderMenu()
        configureCombinedFrequencyMenu()
        configureBuildingFrequencyMenu()
        configureLandlordFrequencyMenu()
        configureSameProviderCheckbox()
        configureFrequencyMenu()
        addDoneToolbarToKeyboards()
        setupInsuranceCalculation()
        populateFieldsIfEditing()
        updateLoanNotes()
        updateRepaymentSummary()
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
        customPaymentsField.isHidden = true
        customRepaymentField.isHidden = true
        repaymentSummaryLabel.isHidden = true
        loanContainer.addArrangedSubview(customPaymentsField)
        loanContainer.addArrangedSubview(customRepaymentField)
        loanContainer.addArrangedSubview(repaymentSummaryLabel)
        loanContainer.addArrangedSubview(loanNotesLabel)
        contentStack.addArrangedSubview(loanContainer)

        contentStack.addArrangedSubview(Divider())

        // Insurance header
        contentStack.addArrangedSubview(insuranceHeader)
        contentStack.addArrangedSubview(insuranceHintLabel)

        // Insurance container
        insuranceContainer.axis = .vertical
        insuranceContainer.spacing = 14

        // Same provider checkbox row
        let sameProviderRow = UIStackView(arrangedSubviews: [sameProviderCheckbox, sameProviderLabel])
        sameProviderRow.axis = .horizontal
        sameProviderRow.spacing = 12
        sameProviderRow.alignment = .center
        insuranceContainer.addArrangedSubview(sameProviderRow)

        // Combined Insurance Section (shown when same provider is checked)
        combinedContainer.axis = .vertical
        combinedContainer.spacing = 14
        combinedContainer.isHidden = true // Hidden by default

        combinedContainer.addArrangedSubview(combinedInsuranceHeader)

        // Provider dropdown with label
        let combinedProviderStack = UIStackView()
        combinedProviderStack.axis = .vertical
        combinedProviderStack.spacing = 6
        let combinedProviderLabel = UILabel()
        combinedProviderLabel.text = "Provider"
        combinedProviderLabel.font = .systemFont(ofSize: 13, weight: .medium)
        combinedProviderLabel.textColor = .secondaryLabel
        combinedProviderStack.addArrangedSubview(combinedProviderLabel)
        combinedProviderStack.addArrangedSubview(combinedProviderButton)
        combinedContainer.addArrangedSubview(combinedProviderStack)

        // Custom provider field (hidden by default)
        combinedCustomProviderField.isHidden = true
        combinedContainer.addArrangedSubview(combinedCustomProviderField)

        // Combined Frequency and Amount row
        let combinedFrequencyStack = UIStackView()
        combinedFrequencyStack.axis = .vertical
        combinedFrequencyStack.spacing = 6
        let combinedFrequencyLabel = UILabel()
        combinedFrequencyLabel.text = "Frequency"
        combinedFrequencyLabel.font = .systemFont(ofSize: 13, weight: .medium)
        combinedFrequencyLabel.textColor = .secondaryLabel
        combinedFrequencyStack.addArrangedSubview(combinedFrequencyLabel)
        combinedFrequencyStack.addArrangedSubview(combinedFrequencyButton)

        let combinedFrequencyAmountRow = UIStackView(arrangedSubviews: [combinedFrequencyStack, combinedAmountField])
        combinedFrequencyAmountRow.axis = .horizontal
        combinedFrequencyAmountRow.spacing = 12
        combinedFrequencyAmountRow.alignment = .fill
        combinedFrequencyAmountRow.distribution = .fillEqually
        combinedContainer.addArrangedSubview(combinedFrequencyAmountRow)

        // Combined Renewal date row
        let combinedRenewalLabel = UILabel()
        combinedRenewalLabel.text = "Renewal Date"
        combinedRenewalLabel.font = .systemFont(ofSize: 15)
        combinedRenewalLabel.textColor = .label

        let combinedRenewalRow = UIStackView(arrangedSubviews: [combinedRenewalLabel, combinedRenewalDatePicker])
        combinedRenewalRow.axis = .horizontal
        combinedRenewalRow.spacing = 12
        combinedRenewalRow.alignment = .center
        combinedContainer.addArrangedSubview(combinedRenewalRow)

        // Combined yearly repayment display
        combinedContainer.addArrangedSubview(combinedYearlyLabel)

        insuranceContainer.addArrangedSubview(combinedContainer)

        // Building Insurance Section (shown when same provider is not checked)
        buildingContainer.axis = .vertical
        buildingContainer.spacing = 14
        buildingContainer.isHidden = false // Visible by default

        buildingContainer.addArrangedSubview(buildingInsuranceHeader)

        // Provider dropdown with label
        let buildingProviderStack = UIStackView()
        buildingProviderStack.axis = .vertical
        buildingProviderStack.spacing = 6
        let buildingProviderLabel = UILabel()
        buildingProviderLabel.text = "Provider"
        buildingProviderLabel.font = .systemFont(ofSize: 13, weight: .medium)
        buildingProviderLabel.textColor = .secondaryLabel
        buildingProviderStack.addArrangedSubview(buildingProviderLabel)
        buildingProviderStack.addArrangedSubview(buildingProviderButton)
        buildingContainer.addArrangedSubview(buildingProviderStack)

        // Custom provider field (hidden by default)
        buildingCustomProviderField.isHidden = true
        buildingContainer.addArrangedSubview(buildingCustomProviderField)

        // Building Frequency and Amount row
        let buildingFrequencyStack = UIStackView()
        buildingFrequencyStack.axis = .vertical
        buildingFrequencyStack.spacing = 6
        let buildingFrequencyLabel = UILabel()
        buildingFrequencyLabel.text = "Frequency"
        buildingFrequencyLabel.font = .systemFont(ofSize: 13, weight: .medium)
        buildingFrequencyLabel.textColor = .secondaryLabel
        buildingFrequencyStack.addArrangedSubview(buildingFrequencyLabel)
        buildingFrequencyStack.addArrangedSubview(buildingFrequencyButton)

        let buildingFrequencyAmountRow = UIStackView(arrangedSubviews: [buildingFrequencyStack, buildingAmountField])
        buildingFrequencyAmountRow.axis = .horizontal
        buildingFrequencyAmountRow.spacing = 12
        buildingFrequencyAmountRow.alignment = .fill
        buildingFrequencyAmountRow.distribution = .fillEqually
        buildingContainer.addArrangedSubview(buildingFrequencyAmountRow)

        // Building Renewal date row
        let buildingRenewalLabel = UILabel()
        buildingRenewalLabel.text = "Renewal Date"
        buildingRenewalLabel.font = .systemFont(ofSize: 15)
        buildingRenewalLabel.textColor = .label

        let buildingRenewalRow = UIStackView(arrangedSubviews: [buildingRenewalLabel, buildingRenewalDatePicker])
        buildingRenewalRow.axis = .horizontal
        buildingRenewalRow.spacing = 12
        buildingRenewalRow.alignment = .center
        buildingContainer.addArrangedSubview(buildingRenewalRow)

        // Building yearly repayment display
        buildingContainer.addArrangedSubview(buildingYearlyLabel)

        insuranceContainer.addArrangedSubview(buildingContainer)

        // Landlord Insurance Section (shown when same provider is not checked)
        landlordContainer.axis = .vertical
        landlordContainer.spacing = 14
        landlordContainer.isHidden = false // Visible by default

        landlordContainer.addArrangedSubview(landlordInsuranceHeader)

        // Provider dropdown with label
        let landlordProviderStack = UIStackView()
        landlordProviderStack.axis = .vertical
        landlordProviderStack.spacing = 6
        let landlordProviderLabel = UILabel()
        landlordProviderLabel.text = "Provider"
        landlordProviderLabel.font = .systemFont(ofSize: 13, weight: .medium)
        landlordProviderLabel.textColor = .secondaryLabel
        landlordProviderStack.addArrangedSubview(landlordProviderLabel)
        landlordProviderStack.addArrangedSubview(landlordProviderButton)
        landlordContainer.addArrangedSubview(landlordProviderStack)

        // Custom provider field (hidden by default)
        landlordCustomProviderField.isHidden = true
        landlordContainer.addArrangedSubview(landlordCustomProviderField)

        // Landlord Frequency and Amount row
        let landlordFrequencyStack = UIStackView()
        landlordFrequencyStack.axis = .vertical
        landlordFrequencyStack.spacing = 6
        let landlordFrequencyLabel = UILabel()
        landlordFrequencyLabel.text = "Frequency"
        landlordFrequencyLabel.font = .systemFont(ofSize: 13, weight: .medium)
        landlordFrequencyLabel.textColor = .secondaryLabel
        landlordFrequencyStack.addArrangedSubview(landlordFrequencyLabel)
        landlordFrequencyStack.addArrangedSubview(landlordFrequencyButton)

        let landlordFrequencyAmountRow = UIStackView(arrangedSubviews: [landlordFrequencyStack, landlordAmountField])
        landlordFrequencyAmountRow.axis = .horizontal
        landlordFrequencyAmountRow.spacing = 12
        landlordFrequencyAmountRow.alignment = .fill
        landlordFrequencyAmountRow.distribution = .fillEqually
        landlordContainer.addArrangedSubview(landlordFrequencyAmountRow)

        // Landlord Renewal date row
        let landlordRenewalLabel = UILabel()
        landlordRenewalLabel.text = "Renewal Date"
        landlordRenewalLabel.font = .systemFont(ofSize: 15)
        landlordRenewalLabel.textColor = .label

        let landlordRenewalRow = UIStackView(arrangedSubviews: [landlordRenewalLabel, landlordRenewalDatePicker])
        landlordRenewalRow.axis = .horizontal
        landlordRenewalRow.spacing = 12
        landlordRenewalRow.alignment = .center
        landlordContainer.addArrangedSubview(landlordRenewalRow)

        // Landlord yearly repayment display
        landlordContainer.addArrangedSubview(landlordYearlyLabel)

        insuranceContainer.addArrangedSubview(landlordContainer)

        // Total insurance repayment
        insuranceContainer.addArrangedSubview(totalInsuranceLabel)

        contentStack.addArrangedSubview(insuranceContainer)
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

    private func configureCombinedFrequencyMenu() {
        let frequencies = ["Monthly", "Fortnightly", "Yearly"]
        var actions: [UIAction] = []
        for freq in frequencies {
            actions.append(UIAction(title: freq) { [weak self] _ in
                self?.combinedFrequencyButton.setTitle(freq, for: .normal)
                self?.combinedSelectedFrequency = freq
                self?.updateCombinedYearlyDisplay()
            })
        }
        combinedFrequencyButton.menu = UIMenu(children: actions)
        combinedFrequencyButton.showsMenuAsPrimaryAction = true
    }

    private func configureBuildingFrequencyMenu() {
        let frequencies = ["Monthly", "Fortnightly", "Yearly"]
        var actions: [UIAction] = []
        for freq in frequencies {
            actions.append(UIAction(title: freq) { [weak self] _ in
                self?.buildingFrequencyButton.setTitle(freq, for: .normal)
                self?.buildingSelectedFrequency = freq
                self?.updateBuildingYearlyDisplay()
                self?.updateTotalInsuranceDisplay()
            })
        }
        buildingFrequencyButton.menu = UIMenu(children: actions)
        buildingFrequencyButton.showsMenuAsPrimaryAction = true
    }

    private func configureLandlordFrequencyMenu() {
        let frequencies = ["Monthly", "Fortnightly", "Yearly"]
        var actions: [UIAction] = []
        for freq in frequencies {
            actions.append(UIAction(title: freq) { [weak self] _ in
                self?.landlordFrequencyButton.setTitle(freq, for: .normal)
                self?.landlordSelectedFrequency = freq
                self?.updateLandlordYearlyDisplay()
                self?.updateTotalInsuranceDisplay()
            })
        }
        landlordFrequencyButton.menu = UIMenu(children: actions)
        landlordFrequencyButton.showsMenuAsPrimaryAction = true
    }

    private func configureFrequencyMenu() {
        let actions = RepaymentFrequency.allCases.map { freq in
            UIAction(title: freq.rawValue, state: freq == selectedFrequency ? .on : .off) { [weak self] _ in
                guard let self else { return }
                selectedFrequency = freq
                switch freq {
                case .custom:
                    customPaymentsField.isHidden = false
                    frequencyPaymentsPerYear = 0
                    frequencyButton.setTitle("Custom (enter payments/yr)", for: .normal)
                default:
                    customPaymentsField.isHidden = enterRepaymentManuallySwitch.isOn == false
                    frequencyPaymentsPerYear = freq.paymentsPerYear
                    let title = "\(freq.rawValue) (\(Int(freq.paymentsPerYear))/yr)"
                    frequencyButton.setTitle(title, for: .normal)
                }
                updateLoanNotes()
                updateRepaymentSummary()
            }
        }
        frequencyButton.menu = UIMenu(children: actions)
        frequencyButton.showsMenuAsPrimaryAction = true
    }

    @objc private func toggleManualEntry(_ sender: UISwitch) {
        customPaymentsField.isHidden = !sender.isOn && selectedFrequency != .custom ? true : false
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
        if selectedFrequency == .custom {
            return parsedDouble(from: customPaymentsField) ?? 0
        }
        return frequencyPaymentsPerYear
    }

    private func computeRepayment() -> (monthly: Double, yearly: Double) {
        guard let amount = parsedDouble(from: loanAmountField),
              let rate = parsedDouble(from: interestRateField) else {
            return (0, 0)
        }

        let paymentsPerYear = currentPaymentsPerYear()
        guard paymentsPerYear > 0 else { return (0, 0) }

        // Manual override
        if enterRepaymentManuallySwitch.isOn,
           let customPayment = parsedDouble(from: customRepaymentField),
           customPayment > 0 {
            let monthly = (customPayment * paymentsPerYear) / 12
            return (monthly, monthly * 12)
        }

        let periodicRate = (rate / 100) / paymentsPerYear
        if interestOnlySwitch.isOn {
            let monthly = amount * (rate / 100) / 12
            return (monthly, monthly * 12)
        } else {
            let n = assumedLoanTermYears * paymentsPerYear
            guard periodicRate > 0, n > 0 else { return (0, 0) }
            let perPayment = amount * periodicRate / (1 - pow(1 + periodicRate, -n))
            let monthly = perPayment * paymentsPerYear / 12
            return (monthly, monthly * 12)
        }
    }

    private func updateRepaymentSummary() {
        let calc = computeRepayment()
        guard calc.monthly > 0 else {
            repaymentSummaryLabel.isHidden = true
            return
        }

        repaymentSummaryLabel.isHidden = false
        let mode = interestOnlySwitch.isOn ? "Interest-only" : "P&I"
        repaymentSummaryLabel.text = "Est. repayment (\(mode)): $\(Int(calc.monthly).formattedWithSeparator()) / month • $\(Int(calc.yearly).formattedWithSeparator()) / year"
    }

    private func configureCombinedProviderMenu() {
        var actions: [UIAction] = []

        // Add all providers from the list
        for provider in Self.insuranceProviders {
            actions.append(UIAction(title: provider) { [weak self] _ in
                self?.combinedProviderButton.setTitle(provider, for: .normal)
                self?.combinedSelectedProvider = provider
                self?.combinedCustomProviderField.isHidden = true
            })
        }

        // Add "Not in the list" option
        actions.append(UIAction(title: "Not in the list") { [weak self] _ in
            self?.combinedProviderButton.setTitle("Not in the list", for: .normal)
            self?.combinedSelectedProvider = "Not in the list"
            self?.combinedCustomProviderField.isHidden = false
        })

        combinedProviderButton.menu = UIMenu(children: actions)
        combinedProviderButton.showsMenuAsPrimaryAction = true
    }

    private func configureBuildingProviderMenu() {
        var actions: [UIAction] = []

        // Add all providers from the list
        for provider in Self.insuranceProviders {
            actions.append(UIAction(title: provider) { [weak self] _ in
                self?.buildingProviderButton.setTitle(provider, for: .normal)
                self?.buildingSelectedProvider = provider
                self?.buildingCustomProviderField.isHidden = true
            })
        }

        // Add "Not in the list" option
        actions.append(UIAction(title: "Not in the list") { [weak self] _ in
            self?.buildingProviderButton.setTitle("Not in the list", for: .normal)
            self?.buildingSelectedProvider = "Not in the list"
            self?.buildingCustomProviderField.isHidden = false
        })

        buildingProviderButton.menu = UIMenu(children: actions)
        buildingProviderButton.showsMenuAsPrimaryAction = true
    }

    private func configureLandlordProviderMenu() {
        var actions: [UIAction] = []

        // Add all providers from the list
        for provider in Self.insuranceProviders {
            actions.append(UIAction(title: provider) { [weak self] _ in
                self?.landlordProviderButton.setTitle(provider, for: .normal)
                self?.landlordSelectedProvider = provider
                self?.landlordCustomProviderField.isHidden = true
            })
        }

        // Add "Not in the list" option
        actions.append(UIAction(title: "Not in the list") { [weak self] _ in
            self?.landlordProviderButton.setTitle("Not in the list", for: .normal)
            self?.landlordSelectedProvider = "Not in the list"
            self?.landlordCustomProviderField.isHidden = false
        })

        landlordProviderButton.menu = UIMenu(children: actions)
        landlordProviderButton.showsMenuAsPrimaryAction = true
    }

    private func configureSameProviderCheckbox() {
        sameProviderCheckbox.addTarget(self, action: #selector(sameProviderToggled), for: .touchUpInside)
    }

    @objc private func sameProviderToggled() {
        sameProviderCheckbox.isSelected.toggle()

        if sameProviderCheckbox.isSelected {
            // Show combined section, hide separate sections
            combinedContainer.isHidden = false
            buildingContainer.isHidden = true
            landlordContainer.isHidden = true

            // Copy data from building to combined if available
            combinedSelectedProvider = buildingSelectedProvider
            combinedProviderButton.setTitle(buildingSelectedProvider, for: .normal)
            if buildingSelectedProvider == "Not in the list" {
                combinedCustomProviderField.isHidden = false
                if let customProvider = buildingCustomProviderField.textField.text {
                    combinedCustomProviderField.textField.text = customProvider
                }
            } else {
                combinedCustomProviderField.isHidden = true
            }

            if let amount = buildingAmountField.textField.text, !amount.isEmpty {
                combinedAmountField.textField.text = amount
            }
            combinedSelectedFrequency = buildingSelectedFrequency
            combinedFrequencyButton.setTitle(buildingSelectedFrequency, for: .normal)
            combinedRenewalDatePicker.date = buildingRenewalDatePicker.date
            updateCombinedYearlyDisplay()
        } else {
            // Show separate sections, hide combined section
            combinedContainer.isHidden = true
            buildingContainer.isHidden = false
            landlordContainer.isHidden = false

            // Copy data from combined back to building and landlord
            buildingSelectedProvider = combinedSelectedProvider
            landlordSelectedProvider = combinedSelectedProvider
            buildingProviderButton.setTitle(combinedSelectedProvider, for: .normal)
            landlordProviderButton.setTitle(combinedSelectedProvider, for: .normal)

            if combinedSelectedProvider == "Not in the list" {
                buildingCustomProviderField.isHidden = false
                landlordCustomProviderField.isHidden = false
                if let customProvider = combinedCustomProviderField.textField.text {
                    buildingCustomProviderField.textField.text = customProvider
                    landlordCustomProviderField.textField.text = customProvider
                }
            } else {
                buildingCustomProviderField.isHidden = true
                landlordCustomProviderField.isHidden = true
            }

            if let amount = combinedAmountField.textField.text, !amount.isEmpty {
                buildingAmountField.textField.text = amount
                landlordAmountField.textField.text = amount
            }
            buildingSelectedFrequency = combinedSelectedFrequency
            landlordSelectedFrequency = combinedSelectedFrequency
            buildingFrequencyButton.setTitle(combinedSelectedFrequency, for: .normal)
            landlordFrequencyButton.setTitle(combinedSelectedFrequency, for: .normal)
            buildingRenewalDatePicker.date = combinedRenewalDatePicker.date
            landlordRenewalDatePicker.date = combinedRenewalDatePicker.date

            updateBuildingYearlyDisplay()
            updateLandlordYearlyDisplay()
            updateTotalInsuranceDisplay()
        }
    }

    private func setupInsuranceCalculation() {
        combinedAmountField.textField.addTarget(self, action: #selector(combinedAmountDidChange(_:)), for: .editingChanged)
        buildingAmountField.textField.addTarget(self, action: #selector(buildingAmountDidChange(_:)), for: .editingChanged)
        landlordAmountField.textField.addTarget(self, action: #selector(landlordAmountDidChange(_:)), for: .editingChanged)
    }

    @objc private func combinedAmountDidChange(_ textField: UITextField) {
        updateCombinedYearlyDisplay()
    }

    @objc private func buildingAmountDidChange(_ textField: UITextField) {
        updateBuildingYearlyDisplay()
        updateTotalInsuranceDisplay()
    }

    @objc private func landlordAmountDidChange(_ textField: UITextField) {
        updateLandlordYearlyDisplay()
        updateTotalInsuranceDisplay()
    }

    private func updateCombinedYearlyDisplay() {
        guard let amountText = combinedAmountField.textField.text,
              !amountText.isEmpty,
              let amount = Double(amountText.replacingOccurrences(of: ",", with: "")) else {
            combinedYearlyLabel.text = ""
            return
        }

        let yearlyAmount: Double
        if combinedSelectedFrequency == "Yearly" {
            yearlyAmount = amount
            combinedYearlyLabel.text = "Yearly: $\(Int(yearlyAmount).formattedWithSeparator())"
        } else if combinedSelectedFrequency == "Fortnightly" {
            yearlyAmount = amount * 26
            combinedYearlyLabel.text = "Fortnightly: $\(Int(amount).formattedWithSeparator()) • Yearly: $\(Int(yearlyAmount).formattedWithSeparator())"
        } else {
            yearlyAmount = amount * 12
            combinedYearlyLabel.text = "Monthly: $\(Int(amount).formattedWithSeparator()) • Yearly: $\(Int(yearlyAmount).formattedWithSeparator())"
        }
    }

    private func updateBuildingYearlyDisplay() {
        guard let amountText = buildingAmountField.textField.text,
              !amountText.isEmpty,
              let amount = Double(amountText.replacingOccurrences(of: ",", with: "")) else {
            buildingYearlyLabel.text = ""
            return
        }

        let yearlyAmount: Double
        if buildingSelectedFrequency == "Yearly" {
            yearlyAmount = amount
            buildingYearlyLabel.text = "Yearly: $\(Int(yearlyAmount).formattedWithSeparator())"
        } else if buildingSelectedFrequency == "Fortnightly" {
            yearlyAmount = amount * 26
            buildingYearlyLabel.text = "Fortnightly: $\(Int(amount).formattedWithSeparator()) • Yearly: $\(Int(yearlyAmount).formattedWithSeparator())"
        } else {
            yearlyAmount = amount * 12
            buildingYearlyLabel.text = "Monthly: $\(Int(amount).formattedWithSeparator()) • Yearly: $\(Int(yearlyAmount).formattedWithSeparator())"
        }
    }

    private func updateLandlordYearlyDisplay() {
        guard let amountText = landlordAmountField.textField.text,
              !amountText.isEmpty,
              let amount = Double(amountText.replacingOccurrences(of: ",", with: "")) else {
            landlordYearlyLabel.text = ""
            return
        }

        let yearlyAmount: Double
        if landlordSelectedFrequency == "Yearly" {
            yearlyAmount = amount
            landlordYearlyLabel.text = "Yearly: $\(Int(yearlyAmount).formattedWithSeparator())"
        } else if landlordSelectedFrequency == "Fortnightly" {
            yearlyAmount = amount * 26
            landlordYearlyLabel.text = "Fortnightly: $\(Int(amount).formattedWithSeparator()) • Yearly: $\(Int(yearlyAmount).formattedWithSeparator())"
        } else {
            yearlyAmount = amount * 12
            landlordYearlyLabel.text = "Monthly: $\(Int(amount).formattedWithSeparator()) • Yearly: $\(Int(yearlyAmount).formattedWithSeparator())"
        }
    }

    private func updateTotalInsuranceDisplay() {
        let buildingAmount = Double(buildingAmountField.textField.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0
        let landlordAmount = Double(landlordAmountField.textField.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0

        let buildingYearly: Double
        if buildingSelectedFrequency == "Yearly" {
            buildingYearly = buildingAmount
        } else if buildingSelectedFrequency == "Fortnightly" {
            buildingYearly = buildingAmount * 26
        } else {
            buildingYearly = buildingAmount * 12
        }

        let landlordYearly: Double
        if landlordSelectedFrequency == "Yearly" {
            landlordYearly = landlordAmount
        } else if landlordSelectedFrequency == "Fortnightly" {
            landlordYearly = landlordAmount * 26
        } else {
            landlordYearly = landlordAmount * 12
        }

        let total = buildingYearly + landlordYearly

        if total > 0 {
            totalInsuranceLabel.text = "Total Yearly Insurance: $\(Int(total).formattedWithSeparator())"
        } else {
            totalInsuranceLabel.text = ""
        }
    }

    // Add "Done" toolbar for number pads
    private func addDoneToolbarToKeyboards() {
        [purchaseField.textField,
         currentValueField.textField,
         loanAmountField.textField,
         interestRateField.textField,
         customPaymentsField.textField,
         customRepaymentField.textField,
         combinedAmountField.textField,
         buildingAmountField.textField,
         landlordAmountField.textField].forEach { tf in
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
        customPaymentsField.textField.delegate = self
        customPaymentsField.textField.addTarget(self, action: #selector(fieldDidChange), for: .editingChanged)
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
            frequencyPaymentsPerYear = Double(freqPerYear)
            switch freqPerYear {
            case 52: selectedFrequency = .weekly; frequencyButton.setTitle("Weekly (52/yr)", for: .normal)
            case 26: selectedFrequency = .fortnightly; frequencyButton.setTitle("Fortnightly (26/yr)", for: .normal)
            case 12: selectedFrequency = .monthly; frequencyButton.setTitle("Monthly (12/yr)", for: .normal)
            default:
                selectedFrequency = .custom
                frequencyButton.setTitle("Custom (enter payments/yr)", for: .normal)
                customPaymentsField.textField.text = "\(freqPerYear)"
                customPaymentsField.isHidden = false
            }

            if loan.usesManualRepayment {
                enterRepaymentManuallySwitch.isOn = true
                customRepaymentField.isHidden = false
                if loan.customPaymentPerPeriod > 0 {
                    customRepaymentField.textField.text = String(format: "%.0f", loan.customPaymentPerPeriod)
                }
            }
        }
        updateRepaymentSummary()

        if let insurance = property.insurance {
            // Check if both insurances have the same data (sameProvider flag)
            if insurance.sameProvider {
                // Show combined section
                sameProviderCheckbox.isSelected = true
                combinedContainer.isHidden = false
                buildingContainer.isHidden = true
                landlordContainer.isHidden = true

                // Set provider button and custom field
                let provider = insurance.buildingProvider
                if Self.insuranceProviders.contains(provider) {
                    combinedSelectedProvider = provider
                    combinedProviderButton.setTitle(provider, for: .normal)
                    combinedCustomProviderField.isHidden = true
                } else {
                    combinedSelectedProvider = "Not in the list"
                    combinedProviderButton.setTitle("Not in the list", for: .normal)
                    combinedCustomProviderField.textField.text = provider
                    combinedCustomProviderField.isHidden = false
                }

                combinedSelectedFrequency = insurance.buildingFrequency
                combinedFrequencyButton.setTitle(insurance.buildingFrequency, for: .normal)
                combinedAmountField.textField.text = "\(insurance.buildingAmount)"
                if let renewalDate = insurance.buildingRenewalDate {
                    combinedRenewalDatePicker.date = renewalDate
                }
                updateCombinedYearlyDisplay()
            } else {
                // Show separate sections
                sameProviderCheckbox.isSelected = false
                combinedContainer.isHidden = true
                buildingContainer.isHidden = false
                landlordContainer.isHidden = false

                // Building insurance - set provider button and custom field
                let buildingProvider = insurance.buildingProvider
                if Self.insuranceProviders.contains(buildingProvider) {
                    buildingSelectedProvider = buildingProvider
                    buildingProviderButton.setTitle(buildingProvider, for: .normal)
                    buildingCustomProviderField.isHidden = true
                } else {
                    buildingSelectedProvider = "Not in the list"
                    buildingProviderButton.setTitle("Not in the list", for: .normal)
                    buildingCustomProviderField.textField.text = buildingProvider
                    buildingCustomProviderField.isHidden = false
                }

                buildingSelectedFrequency = insurance.buildingFrequency
                buildingFrequencyButton.setTitle(insurance.buildingFrequency, for: .normal)
                buildingAmountField.textField.text = "\(insurance.buildingAmount)"
                if let renewalDate = insurance.buildingRenewalDate {
                    buildingRenewalDatePicker.date = renewalDate
                }

                // Landlord insurance - set provider button and custom field
                let landlordProvider = insurance.landlordProvider
                if Self.insuranceProviders.contains(landlordProvider) {
                    landlordSelectedProvider = landlordProvider
                    landlordProviderButton.setTitle(landlordProvider, for: .normal)
                    landlordCustomProviderField.isHidden = true
                } else {
                    landlordSelectedProvider = "Not in the list"
                    landlordProviderButton.setTitle("Not in the list", for: .normal)
                    landlordCustomProviderField.textField.text = landlordProvider
                    landlordCustomProviderField.isHidden = false
                }

                landlordSelectedFrequency = insurance.landlordFrequency
                landlordFrequencyButton.setTitle(insurance.landlordFrequency, for: .normal)
                landlordAmountField.textField.text = "\(insurance.landlordAmount)"
                if let renewalDate = insurance.landlordRenewalDate {
                    landlordRenewalDatePicker.date = renewalDate
                }

                updateBuildingYearlyDisplay()
                updateLandlordYearlyDisplay()
                updateTotalInsuranceDisplay()
            }
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

                loanData = (amount, rate, loanType, calc.monthly, Int(paymentsPerYear), customPerPeriod, enterRepaymentManuallySwitch.isOn)
            }
        }

        // Extract insurance data if provided
        var insuranceData: (
            buildingProvider: String, buildingFrequency: String, buildingAmount: Double, buildingRenewalDate: Date?,
            landlordProvider: String, landlordFrequency: String, landlordAmount: Double, landlordRenewalDate: Date?,
            sameProvider: Bool
        )? = nil

        if sameProviderCheckbox.isSelected {
            // Using combined section
            let hasProviderSelected = combinedSelectedProvider != "Select Provider"
            let hasAmount = !(combinedAmountField.textField.text ?? "").isEmpty

            if hasProviderSelected || hasAmount {
                // Get provider from button or custom field
                var provider: String
                if combinedSelectedProvider == "Not in the list" {
                    guard let customProvider = combinedCustomProviderField.textField.text, !customProvider.isEmpty else {
                        showAlert("Please enter a custom insurance provider."); return
                    }
                    provider = customProvider
                } else if combinedSelectedProvider == "Select Provider" {
                    showAlert("Please select an insurance provider."); return
                } else {
                    provider = combinedSelectedProvider
                }

                guard let amountText = combinedAmountField.textField.text,
                      !amountText.isEmpty,
                      let amt = Double(amountText.replacingOccurrences(of: ",", with: "")), amt > 0 else {
                    showAlert("Please enter an insurance repayment amount."); return
                }

                // Use same data for both building and landlord
                insuranceData = (
                    buildingProvider: provider,
                    buildingFrequency: combinedSelectedFrequency,
                    buildingAmount: amt,
                    buildingRenewalDate: combinedRenewalDatePicker.date,
                    landlordProvider: provider,
                    landlordFrequency: combinedSelectedFrequency,
                    landlordAmount: amt,
                    landlordRenewalDate: combinedRenewalDatePicker.date,
                    sameProvider: true
                )
            }
        } else {
            // Using separate sections
            let hasBuildingProviderSelected = buildingSelectedProvider != "Select Provider"
            let hasBuildingAmount = !(buildingAmountField.textField.text ?? "").isEmpty
            let hasLandlordProviderSelected = landlordSelectedProvider != "Select Provider"
            let hasLandlordAmount = !(landlordAmountField.textField.text ?? "").isEmpty

            let hasBuildingInsurance = hasBuildingProviderSelected || hasBuildingAmount
            let hasLandlordInsurance = hasLandlordProviderSelected || hasLandlordAmount

            if hasBuildingInsurance || hasLandlordInsurance {
                var buildingProvider = ""
                var buildingAmount: Double = 0
                var landlordProvider = ""
                var landlordAmount: Double = 0

                // Validate building insurance
                if hasBuildingInsurance {
                    // Get provider from button or custom field
                    if buildingSelectedProvider == "Not in the list" {
                        guard let customProvider = buildingCustomProviderField.textField.text, !customProvider.isEmpty else {
                            showAlert("Please enter a custom building insurance provider."); return
                        }
                        buildingProvider = customProvider
                    } else if buildingSelectedProvider == "Select Provider" {
                        showAlert("Please select a building insurance provider."); return
                    } else {
                        buildingProvider = buildingSelectedProvider
                    }

                    guard let amountText = buildingAmountField.textField.text,
                          !amountText.isEmpty,
                          let amt = Double(amountText.replacingOccurrences(of: ",", with: "")), amt > 0 else {
                        showAlert("Please enter a building insurance repayment amount."); return
                    }
                    buildingAmount = amt
                }

                // Validate landlord insurance
                if hasLandlordInsurance {
                    // Get provider from button or custom field
                    if landlordSelectedProvider == "Not in the list" {
                        guard let customProvider = landlordCustomProviderField.textField.text, !customProvider.isEmpty else {
                            showAlert("Please enter a custom landlord insurance provider."); return
                        }
                        landlordProvider = customProvider
                    } else if landlordSelectedProvider == "Select Provider" {
                        showAlert("Please select a landlord insurance provider."); return
                    } else {
                        landlordProvider = landlordSelectedProvider
                    }

                    guard let amountText = landlordAmountField.textField.text,
                          !amountText.isEmpty,
                          let amt = Double(amountText.replacingOccurrences(of: ",", with: "")), amt > 0 else {
                        showAlert("Please enter a landlord insurance repayment amount."); return
                    }
                    landlordAmount = amt
                }

                insuranceData = (
                    buildingProvider: buildingProvider,
                    buildingFrequency: buildingSelectedFrequency,
                    buildingAmount: buildingAmount,
                    buildingRenewalDate: buildingRenewalDatePicker.date,
                    landlordProvider: landlordProvider,
                    landlordFrequency: landlordSelectedFrequency,
                    landlordAmount: landlordAmount,
                    landlordRenewalDate: landlordRenewalDatePicker.date,
                    sameProvider: false
                )
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
                                    rentalIncome: rentalIncome,
                                    managementFeePercent: managementFeePercent,
                                    estimatedExpensesAmount: expensesParsed.amount,
                                    expensesAreMonthly: expensesParsed.isMonthly,
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
            property.expensesAreMonthly = expensesParsed.isMonthly

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
