import UIKit

/// Encapsulates the insurance form UI and validation.
final class InsuranceSectionView: UIView {
    struct InsuranceData {
        let buildingProvider: String
        let buildingFrequency: String
        let buildingAmount: Double
        let buildingRenewalDate: Date?
        let landlordProvider: String
        let landlordFrequency: String
        let landlordAmount: Double
        let landlordRenewalDate: Date?
        let sameProvider: Bool
    }

    enum InsuranceDataResult {
        case none
        case valid(InsuranceData)
        case invalid
    }

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
    private struct SplitInsuranceState {
        let buildingProvider: String
        let buildingCustomProvider: String
        let buildingFrequency: String
        let buildingAmount: String
        let buildingDate: Date
        let landlordProvider: String
        let landlordCustomProvider: String
        let landlordFrequency: String
        let landlordAmount: String
        let landlordDate: Date
    }

    // MARK: - UI
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
    private let combinedAnnuallyLabel: UILabel = {
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
    private let buildingAnnuallyLabel: UILabel = {
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
    private let landlordAnnuallyLabel: UILabel = {
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
    private var splitInsuranceCache: SplitInsuranceState?

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
        configureMenus()
        setupInsuranceCalculation()
        configureSameProviderCheckbox()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Exposed helpers
    var numericTextFields: [UITextField] {
        [combinedAmountField.textField,
         buildingAmountField.textField,
         landlordAmountField.textField]
    }

    func populate(with insurance: PropertyInsurance?) {
        guard let insurance else {
            resetFields()
            return
        }

        if insurance.sameProvider {
            sameProviderCheckbox.isSelected = true
            combinedContainer.isHidden = false
            buildingContainer.isHidden = true
            landlordContainer.isHidden = true

            setProviderButton(combinedProviderButton,
                              selected: &combinedSelectedProvider,
                              customField: combinedCustomProviderField,
                              provider: insurance.buildingProvider)

            combinedSelectedFrequency = insurance.buildingFrequency
            combinedFrequencyButton.setTitle(insurance.buildingFrequency, for: .normal)
            combinedAmountField.textField.text = "\(insurance.buildingAmount)"
            if let renewalDate = insurance.buildingRenewalDate {
                combinedRenewalDatePicker.date = renewalDate
            }
            updateCombinedAnnuallyDisplay()
            updateTotalInsuranceDisplay()
        } else {
            sameProviderCheckbox.isSelected = false
            combinedContainer.isHidden = true
            buildingContainer.isHidden = false
            landlordContainer.isHidden = false

            setProviderButton(buildingProviderButton,
                              selected: &buildingSelectedProvider,
                              customField: buildingCustomProviderField,
                              provider: insurance.buildingProvider)
            buildingSelectedFrequency = insurance.buildingFrequency
            buildingFrequencyButton.setTitle(insurance.buildingFrequency, for: .normal)
            buildingAmountField.textField.text = "\(insurance.buildingAmount)"
            if let renewalDate = insurance.buildingRenewalDate {
                buildingRenewalDatePicker.date = renewalDate
            }

            setProviderButton(landlordProviderButton,
                              selected: &landlordSelectedProvider,
                              customField: landlordCustomProviderField,
                              provider: insurance.landlordProvider)
            landlordSelectedFrequency = insurance.landlordFrequency
            landlordFrequencyButton.setTitle(insurance.landlordFrequency, for: .normal)
            landlordAmountField.textField.text = "\(insurance.landlordAmount)"
            if let renewalDate = insurance.landlordRenewalDate {
                landlordRenewalDatePicker.date = renewalDate
            }

            updateBuildingAnnuallyDisplay()
            updateLandlordAnnuallyDisplay()
            updateTotalInsuranceDisplay()
        }
    }

    func insuranceData(onValidationError: (String) -> Void) -> InsuranceDataResult {
        if sameProviderCheckbox.isSelected {
            let hasProviderSelected = combinedSelectedProvider != "Select Provider"
            let hasAmount = !(combinedAmountField.textField.text ?? "").isEmpty

            if !(hasProviderSelected || hasAmount) {
                return .none
            }

            guard let provider = resolvedProvider(selectedProvider: combinedSelectedProvider,
                                                  customField: combinedCustomProviderField,
                                                  onValidationError: onValidationError) else {
                return .invalid
            }

            guard let amount = parsedAmount(from: combinedAmountField) else {
                onValidationError("Please enter an insurance repayment amount.")
                return .invalid
            }

            let data = InsuranceData(
                buildingProvider: provider,
                buildingFrequency: combinedSelectedFrequency,
                buildingAmount: amount,
                buildingRenewalDate: combinedRenewalDatePicker.date,
                landlordProvider: provider,
                landlordFrequency: combinedSelectedFrequency,
                landlordAmount: amount,
                landlordRenewalDate: combinedRenewalDatePicker.date,
                sameProvider: true
            )
            return .valid(data)
        } else {
            let hasBuildingProviderSelected = buildingSelectedProvider != "Select Provider"
            let hasBuildingAmount = !(buildingAmountField.textField.text ?? "").isEmpty
            let hasLandlordProviderSelected = landlordSelectedProvider != "Select Provider"
            let hasLandlordAmount = !(landlordAmountField.textField.text ?? "").isEmpty

            let hasBuildingInsurance = hasBuildingProviderSelected || hasBuildingAmount
            let hasLandlordInsurance = hasLandlordProviderSelected || hasLandlordAmount

            if !(hasBuildingInsurance || hasLandlordInsurance) {
                return .none
            }

            var buildingProvider = ""
            var buildingAmount: Double = 0
            var landlordProvider = ""
            var landlordAmount: Double = 0

            if hasBuildingInsurance {
                guard let provider = resolvedProvider(selectedProvider: buildingSelectedProvider,
                                                      customField: buildingCustomProviderField,
                                                      onValidationError: onValidationError) else {
                    return .invalid
                }
                buildingProvider = provider

                guard let amount = parsedAmount(from: buildingAmountField) else {
                    onValidationError("Please enter a building insurance repayment amount.")
                    return .invalid
                }
                buildingAmount = amount
            }

            if hasLandlordInsurance {
                guard let provider = resolvedProvider(selectedProvider: landlordSelectedProvider,
                                                      customField: landlordCustomProviderField,
                                                      onValidationError: onValidationError) else {
                    return .invalid
                }
                landlordProvider = provider

                guard let amount = parsedAmount(from: landlordAmountField) else {
                    onValidationError("Please enter a landlord insurance repayment amount.")
                    return .invalid
                }
                landlordAmount = amount
            }

            let data = InsuranceData(
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
            return .valid(data)
        }
    }

    // MARK: - Layout
    private func buildLayout() {
        insuranceContainer.axis = .vertical
        insuranceContainer.spacing = 14
        insuranceContainer.translatesAutoresizingMaskIntoConstraints = false

        let sameProviderRow = UIStackView(arrangedSubviews: [sameProviderCheckbox, sameProviderLabel])
        sameProviderRow.axis = .horizontal
        sameProviderRow.spacing = 12
        sameProviderRow.alignment = .center
        insuranceContainer.addArrangedSubview(insuranceHeader)
        insuranceContainer.addArrangedSubview(insuranceHintLabel)
        insuranceContainer.addArrangedSubview(sameProviderRow)

        combinedContainer.axis = .vertical
        combinedContainer.spacing = 14
        combinedContainer.isHidden = true
        combinedContainer.addArrangedSubview(combinedInsuranceHeader)

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

        combinedCustomProviderField.isHidden = true
        combinedContainer.addArrangedSubview(combinedCustomProviderField)

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

        let combinedRenewalLabel = UILabel()
        combinedRenewalLabel.text = "Renewal Date"
        combinedRenewalLabel.font = .systemFont(ofSize: 15)
        combinedRenewalLabel.textColor = .label

        let combinedRenewalRow = UIStackView(arrangedSubviews: [combinedRenewalLabel, combinedRenewalDatePicker])
        combinedRenewalRow.axis = .horizontal
        combinedRenewalRow.spacing = 12
        combinedRenewalRow.alignment = .center
        combinedContainer.addArrangedSubview(combinedRenewalRow)

        combinedContainer.addArrangedSubview(combinedAnnuallyLabel)

        insuranceContainer.addArrangedSubview(combinedContainer)

        buildingContainer.axis = .vertical
        buildingContainer.spacing = 14
        buildingContainer.isHidden = false
        buildingContainer.addArrangedSubview(buildingInsuranceHeader)

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

        buildingCustomProviderField.isHidden = true
        buildingContainer.addArrangedSubview(buildingCustomProviderField)

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

        let buildingRenewalLabel = UILabel()
        buildingRenewalLabel.text = "Renewal Date"
        buildingRenewalLabel.font = .systemFont(ofSize: 15)
        buildingRenewalLabel.textColor = .label

        let buildingRenewalRow = UIStackView(arrangedSubviews: [buildingRenewalLabel, buildingRenewalDatePicker])
        buildingRenewalRow.axis = .horizontal
        buildingRenewalRow.spacing = 12
        buildingRenewalRow.alignment = .center
        buildingContainer.addArrangedSubview(buildingRenewalRow)

        buildingContainer.addArrangedSubview(buildingAnnuallyLabel)
        insuranceContainer.addArrangedSubview(buildingContainer)

        landlordContainer.axis = .vertical
        landlordContainer.spacing = 14
        landlordContainer.isHidden = false

        landlordContainer.addArrangedSubview(landlordInsuranceHeader)

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

        landlordCustomProviderField.isHidden = true
        landlordContainer.addArrangedSubview(landlordCustomProviderField)

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

        let landlordRenewalLabel = UILabel()
        landlordRenewalLabel.text = "Renewal Date"
        landlordRenewalLabel.font = .systemFont(ofSize: 15)
        landlordRenewalLabel.textColor = .label

        let landlordRenewalRow = UIStackView(arrangedSubviews: [landlordRenewalLabel, landlordRenewalDatePicker])
        landlordRenewalRow.axis = .horizontal
        landlordRenewalRow.spacing = 12
        landlordRenewalRow.alignment = .center
        landlordContainer.addArrangedSubview(landlordRenewalRow)

        landlordContainer.addArrangedSubview(landlordAnnuallyLabel)

        insuranceContainer.addArrangedSubview(landlordContainer)

        insuranceContainer.addArrangedSubview(totalInsuranceLabel)

        addSubview(insuranceContainer)
        NSLayoutConstraint.activate([
            insuranceContainer.topAnchor.constraint(equalTo: topAnchor),
            insuranceContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            insuranceContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            insuranceContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Menus and Actions
    private func configureMenus() {
        configureCombinedProviderMenu()
        configureBuildingProviderMenu()
        configureLandlordProviderMenu()
        configureCombinedFrequencyMenu()
        configureBuildingFrequencyMenu()
        configureLandlordFrequencyMenu()
    }

    private func configureCombinedFrequencyMenu() {
        let frequencies = ["Monthly", "Fortnightly", "Annually"]
        let actions = frequencies.map { freq in
            UIAction(title: freq) { [weak self] _ in
                self?.combinedFrequencyButton.setTitle(freq, for: .normal)
                self?.combinedSelectedFrequency = freq
                self?.updateCombinedAnnuallyDisplay()
                self?.updateTotalInsuranceDisplay()
            }
        }
        combinedFrequencyButton.menu = UIMenu(children: actions)
        combinedFrequencyButton.showsMenuAsPrimaryAction = true
    }

    private func configureBuildingFrequencyMenu() {
        let frequencies = ["Monthly", "Fortnightly", "Annually"]
        let actions = frequencies.map { freq in
            UIAction(title: freq) { [weak self] _ in
                self?.buildingFrequencyButton.setTitle(freq, for: .normal)
                self?.buildingSelectedFrequency = freq
                self?.updateBuildingAnnuallyDisplay()
                self?.updateTotalInsuranceDisplay()
            }
        }
        buildingFrequencyButton.menu = UIMenu(children: actions)
        buildingFrequencyButton.showsMenuAsPrimaryAction = true
    }

    private func configureLandlordFrequencyMenu() {
        let frequencies = ["Monthly", "Fortnightly", "Annually"]
        let actions = frequencies.map { freq in
            UIAction(title: freq) { [weak self] _ in
                self?.landlordFrequencyButton.setTitle(freq, for: .normal)
                self?.landlordSelectedFrequency = freq
                self?.updateLandlordAnnuallyDisplay()
                self?.updateTotalInsuranceDisplay()
            }
        }
        landlordFrequencyButton.menu = UIMenu(children: actions)
        landlordFrequencyButton.showsMenuAsPrimaryAction = true
    }

    private func configureCombinedProviderMenu() {
        var actions: [UIAction] = []
        for provider in Self.insuranceProviders {
            actions.append(UIAction(title: provider) { [weak self] _ in
                self?.combinedProviderButton.setTitle(provider, for: .normal)
                self?.combinedSelectedProvider = provider
                self?.combinedCustomProviderField.isHidden = true
            })
        }
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
        for provider in Self.insuranceProviders {
            actions.append(UIAction(title: provider) { [weak self] _ in
                self?.buildingProviderButton.setTitle(provider, for: .normal)
                self?.buildingSelectedProvider = provider
                self?.buildingCustomProviderField.isHidden = true
            })
        }
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
        for provider in Self.insuranceProviders {
            actions.append(UIAction(title: provider) { [weak self] _ in
                self?.landlordProviderButton.setTitle(provider, for: .normal)
                self?.landlordSelectedProvider = provider
                self?.landlordCustomProviderField.isHidden = true
            })
        }
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
            splitInsuranceCache = SplitInsuranceState(
                buildingProvider: buildingSelectedProvider,
                buildingCustomProvider: buildingCustomProviderField.textField.text ?? "",
                buildingFrequency: buildingSelectedFrequency,
                buildingAmount: buildingAmountField.textField.text ?? "",
                buildingDate: buildingRenewalDatePicker.date,
                landlordProvider: landlordSelectedProvider,
                landlordCustomProvider: landlordCustomProviderField.textField.text ?? "",
                landlordFrequency: landlordSelectedFrequency,
                landlordAmount: landlordAmountField.textField.text ?? "",
                landlordDate: landlordRenewalDatePicker.date
            )

            combinedContainer.isHidden = false
            buildingContainer.isHidden = true
            landlordContainer.isHidden = true

            combinedSelectedProvider = buildingSelectedProvider
            combinedProviderButton.setTitle(buildingSelectedProvider, for: .normal)
            if buildingSelectedProvider == "Not in the list" {
                combinedCustomProviderField.isHidden = false
                combinedCustomProviderField.textField.text = buildingCustomProviderField.textField.text
            } else {
                combinedCustomProviderField.isHidden = true
            }

            combinedAmountField.textField.text = buildingAmountField.textField.text
            combinedSelectedFrequency = buildingSelectedFrequency
            combinedFrequencyButton.setTitle(buildingSelectedFrequency, for: .normal)
            combinedRenewalDatePicker.date = buildingRenewalDatePicker.date
            updateCombinedAnnuallyDisplay()
            updateTotalInsuranceDisplay()
        } else {
            combinedContainer.isHidden = true
            buildingContainer.isHidden = false
            landlordContainer.isHidden = false

            if let cached = splitInsuranceCache {
                buildingSelectedProvider = cached.buildingProvider
                buildingProviderButton.setTitle(cached.buildingProvider, for: .normal)
                landlordSelectedProvider = cached.landlordProvider
                landlordProviderButton.setTitle(cached.landlordProvider, for: .normal)

                if cached.buildingProvider == "Not in the list" {
                    buildingCustomProviderField.isHidden = false
                    buildingCustomProviderField.textField.text = cached.buildingCustomProvider
                } else {
                    buildingCustomProviderField.isHidden = true
                    buildingCustomProviderField.textField.text = nil
                }

                if cached.landlordProvider == "Not in the list" {
                    landlordCustomProviderField.isHidden = false
                    landlordCustomProviderField.textField.text = cached.landlordCustomProvider
                } else {
                    landlordCustomProviderField.isHidden = true
                    landlordCustomProviderField.textField.text = nil
                }

                buildingAmountField.textField.text = cached.buildingAmount
                landlordAmountField.textField.text = cached.landlordAmount
                buildingSelectedFrequency = cached.buildingFrequency
                landlordSelectedFrequency = cached.landlordFrequency
                buildingFrequencyButton.setTitle(cached.buildingFrequency, for: .normal)
                landlordFrequencyButton.setTitle(cached.landlordFrequency, for: .normal)
                buildingRenewalDatePicker.date = cached.buildingDate
                landlordRenewalDatePicker.date = cached.landlordDate
                splitInsuranceCache = nil
            } else {
                buildingSelectedProvider = "Select Provider"
                landlordSelectedProvider = "Select Provider"
                buildingProviderButton.setTitle("Select Provider", for: .normal)
                landlordProviderButton.setTitle("Select Provider", for: .normal)
                buildingCustomProviderField.isHidden = true
                landlordCustomProviderField.isHidden = true
                buildingCustomProviderField.textField.text = nil
                landlordCustomProviderField.textField.text = nil
                buildingAmountField.textField.text = nil
                landlordAmountField.textField.text = nil
                buildingSelectedFrequency = "Monthly"
                landlordSelectedFrequency = "Monthly"
                buildingFrequencyButton.setTitle("Monthly", for: .normal)
                landlordFrequencyButton.setTitle("Monthly", for: .normal)
                buildingRenewalDatePicker.date = Date()
                landlordRenewalDatePicker.date = Date()
            }

            updateBuildingAnnuallyDisplay()
            updateLandlordAnnuallyDisplay()
            updateTotalInsuranceDisplay()
        }
    }

    // MARK: - Calculations
    private func setupInsuranceCalculation() {
        combinedAmountField.textField.addTarget(self, action: #selector(combinedAmountDidChange(_:)), for: .editingChanged)
        buildingAmountField.textField.addTarget(self, action: #selector(buildingAmountDidChange(_:)), for: .editingChanged)
        landlordAmountField.textField.addTarget(self, action: #selector(landlordAmountDidChange(_:)), for: .editingChanged)
    }

    @objc private func combinedAmountDidChange(_ textField: UITextField) {
        updateCombinedAnnuallyDisplay()
        updateTotalInsuranceDisplay()
    }

    @objc private func buildingAmountDidChange(_ textField: UITextField) {
        updateBuildingAnnuallyDisplay()
        updateTotalInsuranceDisplay()
    }

    @objc private func landlordAmountDidChange(_ textField: UITextField) {
        updateLandlordAnnuallyDisplay()
        updateTotalInsuranceDisplay()
    }

    private func updateCombinedAnnuallyDisplay() {
        guard let amount = parsedAmount(from: combinedAmountField) else {
            combinedAnnuallyLabel.text = ""
            return
        }

        if combinedSelectedFrequency == "Annually" {
            combinedAnnuallyLabel.text = "Annually: $\(Int(amount).formattedWithSeparator())"
        } else if combinedSelectedFrequency == "Fortnightly" {
            let yearlyAmount = amount * 26
            combinedAnnuallyLabel.text = "Fortnightly: $\(Int(amount).formattedWithSeparator()) • Annually: $\(Int(yearlyAmount).formattedWithSeparator())"
        } else {
            let yearlyAmount = amount * 12
            combinedAnnuallyLabel.text = "Monthly: $\(Int(amount).formattedWithSeparator()) • Annually: $\(Int(yearlyAmount).formattedWithSeparator())"
        }
    }

    private func updateBuildingAnnuallyDisplay() {
        guard let amount = parsedAmount(from: buildingAmountField) else {
            buildingAnnuallyLabel.text = ""
            return
        }

        if buildingSelectedFrequency == "Annually" {
            buildingAnnuallyLabel.text = "Annually: $\(Int(amount).formattedWithSeparator())"
        } else if buildingSelectedFrequency == "Fortnightly" {
            let yearlyAmount = amount * 26
            buildingAnnuallyLabel.text = "Fortnightly: $\(Int(amount).formattedWithSeparator()) • Annually: $\(Int(yearlyAmount).formattedWithSeparator())"
        } else {
            let yearlyAmount = amount * 12
            buildingAnnuallyLabel.text = "Monthly: $\(Int(amount).formattedWithSeparator()) • Annually: $\(Int(yearlyAmount).formattedWithSeparator())"
        }
    }

    private func updateLandlordAnnuallyDisplay() {
        guard let amount = parsedAmount(from: landlordAmountField) else {
            landlordAnnuallyLabel.text = ""
            return
        }

        if landlordSelectedFrequency == "Annually" {
            landlordAnnuallyLabel.text = "Annually: $\(Int(amount).formattedWithSeparator())"
        } else if landlordSelectedFrequency == "Fortnightly" {
            let yearlyAmount = amount * 26
            landlordAnnuallyLabel.text = "Fortnightly: $\(Int(amount).formattedWithSeparator()) • Annually: $\(Int(yearlyAmount).formattedWithSeparator())"
        } else {
            let yearlyAmount = amount * 12
            landlordAnnuallyLabel.text = "Monthly: $\(Int(amount).formattedWithSeparator()) • Annually: $\(Int(yearlyAmount).formattedWithSeparator())"
        }
    }

    private func updateTotalInsuranceDisplay() {
        let total: Double
        if sameProviderCheckbox.isSelected {
            guard let amount = parsedAmount(from: combinedAmountField) else {
                totalInsuranceLabel.text = ""
                return
            }

            let annual: Double
            if combinedSelectedFrequency == "Annually" {
                annual = amount
            } else if combinedSelectedFrequency == "Fortnightly" {
                annual = amount * 26
            } else {
                annual = amount * 12
            }
            total = annual
        } else {
            let buildingAmount = parsedAmount(from: buildingAmountField) ?? 0
            let landlordAmount = parsedAmount(from: landlordAmountField) ?? 0

            let buildingAnnually: Double
            if buildingSelectedFrequency == "Annually" {
                buildingAnnually = buildingAmount
            } else if buildingSelectedFrequency == "Fortnightly" {
                buildingAnnually = buildingAmount * 26
            } else {
                buildingAnnually = buildingAmount * 12
            }

            let landlordAnnually: Double
            if landlordSelectedFrequency == "Annually" {
                landlordAnnually = landlordAmount
            } else if landlordSelectedFrequency == "Fortnightly" {
                landlordAnnually = landlordAmount * 26
            } else {
                landlordAnnually = landlordAmount * 12
            }

            total = buildingAnnually + landlordAnnually
        }

        if total > 0 {
            totalInsuranceLabel.text = "Total Annual Insurance: $\(Int(total).formattedWithSeparator())"
        } else {
            totalInsuranceLabel.text = ""
        }
    }

    // MARK: - Helpers
    private func resolvedProvider(selectedProvider: String,
                                  customField: LabeledField,
                                  onValidationError: (String) -> Void) -> String? {
        if selectedProvider == "Not in the list" {
            guard let customProvider = customField.textField.text, !customProvider.isEmpty else {
                onValidationError("Please enter a custom insurance provider.")
                return nil
            }
            return customProvider
        } else if selectedProvider == "Select Provider" {
            onValidationError("Please select an insurance provider.")
            return nil
        } else {
            return selectedProvider
        }
    }

    private func parsedAmount(from field: LabeledField) -> Double? {
        guard let amountText = field.textField.text,
              !amountText.isEmpty,
              let amount = Double(amountText.replacingOccurrences(of: ",", with: "")),
              amount > 0 else { return nil }
        return amount
    }

    private func setProviderButton(_ button: UIButton,
                                   selected: inout String,
                                   customField: LabeledField,
                                   provider: String) {
        if Self.insuranceProviders.contains(provider) {
            selected = provider
            button.setTitle(provider, for: .normal)
            customField.isHidden = true
        } else {
            selected = "Not in the list"
            button.setTitle("Not in the list", for: .normal)
            customField.textField.text = provider
            customField.isHidden = false
        }
    }

    private func resetFields() {
        combinedSelectedProvider = "Select Provider"
        buildingSelectedProvider = "Select Provider"
        landlordSelectedProvider = "Select Provider"
        splitInsuranceCache = nil
        combinedProviderButton.setTitle("Select Provider", for: .normal)
        buildingProviderButton.setTitle("Select Provider", for: .normal)
        landlordProviderButton.setTitle("Select Provider", for: .normal)
        combinedCustomProviderField.textField.text = nil
        buildingCustomProviderField.textField.text = nil
        landlordCustomProviderField.textField.text = nil
        combinedAmountField.textField.text = nil
        buildingAmountField.textField.text = nil
        landlordAmountField.textField.text = nil
        combinedAnnuallyLabel.text = ""
        buildingAnnuallyLabel.text = ""
        landlordAnnuallyLabel.text = ""
        totalInsuranceLabel.text = ""
        sameProviderCheckbox.isSelected = false
        combinedContainer.isHidden = true
        buildingContainer.isHidden = false
        landlordContainer.isHidden = false
    }
}
