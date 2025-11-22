import UIKit

final class AddLiabilityViewController: UIViewController {

    weak var coordinator: MainCoordinator?
    private let viewModel: LiabilityViewModel
    private let liabilityToEdit: Liability?

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // Liability details
    private let nameField = LabeledField(title: "Name",
                                         placeholder: "e.g., Credit Card, Personal Loan")
    private let typeField = LabeledField(title: "Type",
                                        placeholder: "e.g., Credit Card, Personal Loan, HECS-HELP")

    // Financial details
    private let balanceField = LabeledField(title: "Balance Owed ($)",
                                           placeholder: "10,000",
                                           keyboard: .numberPad)
    private let interestRateField = LabeledField(title: "Interest Rate (%) - Optional",
                                                placeholder: "5.5",
                                                keyboard: .decimalPad)
    private let minimumPaymentField = LabeledField(title: "Minimum Payment ($) - Optional",
                                                   placeholder: "200",
                                                   keyboard: .numberPad)

    // Due date
    private let dueDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Due Date (Optional)"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let dueDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private let hasDueDateSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    private let notesField = LabeledField(title: "Notes (optional)",
                                         placeholder: "Additional information")

    // MARK: - Init
    init(viewModel: LiabilityViewModel, liabilityToEdit: Liability? = nil) {
        self.viewModel = viewModel
        self.liabilityToEdit = liabilityToEdit
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = liabilityToEdit == nil ? "Add Liability" : "Edit Liability"
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
    private func createInfoNote() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        container.layer.cornerRadius = 8

        let iconImageView = UIImageView(image: UIImage(systemName: "info.circle.fill"))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Don't add mortgage or home loan debt here. It's already calculated in Properties when you add your property."
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0

        container.addSubview(iconImageView)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])

        return container
    }

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

        // Liability Details
        contentStack.addArrangedSubview(FormSectionHeader("Liability Details"))

        // Info note
        let infoView = createInfoNote()
        contentStack.addArrangedSubview(infoView)

        contentStack.addArrangedSubview(nameField)
        contentStack.addArrangedSubview(typeField)

        contentStack.addArrangedSubview(Divider())

        // Financial Details
        contentStack.addArrangedSubview(FormSectionHeader("Financial Details"))
        contentStack.addArrangedSubview(balanceField)
        contentStack.addArrangedSubview(interestRateField)
        contentStack.addArrangedSubview(minimumPaymentField)

        contentStack.addArrangedSubview(Divider())

        // Due Date
        contentStack.addArrangedSubview(FormSectionHeader("Payment Information"))

        let dueDateContainer = UIStackView()
        dueDateContainer.axis = .horizontal
        dueDateContainer.spacing = 12
        dueDateContainer.alignment = .center
        dueDateContainer.translatesAutoresizingMaskIntoConstraints = false

        dueDateContainer.addArrangedSubview(dueDateLabel)
        dueDateContainer.addArrangedSubview(hasDueDateSwitch)

        contentStack.addArrangedSubview(dueDateContainer)
        contentStack.addArrangedSubview(dueDatePicker)

        dueDatePicker.isHidden = true
        hasDueDateSwitch.addTarget(self, action: #selector(dueDateToggled), for: .valueChanged)

        contentStack.addArrangedSubview(Divider())

        // Notes
        contentStack.addArrangedSubview(FormSectionHeader("Additional Information"))
        contentStack.addArrangedSubview(notesField)
    }

    // Add "Done" toolbar for number pads
    private func addDoneToolbarToKeyboards() {
        [balanceField.textField,
         interestRateField.textField,
         minimumPaymentField.textField].forEach { tf in
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

        minimumPaymentField.textField.delegate = self
        minimumPaymentField.textField.addTarget(self, action: #selector(currencyFieldDidChange(_:)), for: .editingChanged)
    }

    @objc private func currencyFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }

        // Remove commas and format with commas
        let numbersOnly = text.replacingOccurrences(of: ",", with: "")
        if let number = Int(numbersOnly) {
            textField.text = number.formattedWithSeparator()
        }
    }

    @objc private func dueDateToggled() {
        dueDatePicker.isHidden = !hasDueDateSwitch.isOn
    }

    private func populateFieldsIfEditing() {
        guard let liability = liabilityToEdit else { return }

        nameField.textField.text = liability.name
        typeField.textField.text = liability.type
        balanceField.textField.text = Int(liability.balance).formattedWithSeparator()
        interestRateField.textField.text = liability.interestRate > 0 ? "\(liability.interestRate)" : ""
        minimumPaymentField.textField.text = liability.minimumPayment > 0 ? Int(liability.minimumPayment).formattedWithSeparator() : ""
        notesField.textField.text = liability.notes

        if let dueDate = liability.dueDate {
            hasDueDateSwitch.isOn = true
            dueDatePicker.isHidden = false
            dueDatePicker.date = dueDate
        }
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        // Basic validation
        guard let name = nameField.textField.text, !name.isEmpty else {
            showAlert("Please enter a name."); return
        }
        guard let type = typeField.textField.text, !type.isEmpty else {
            showAlert("Please enter a type."); return
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

        let minimumPayment: Double
        let minPaymentText = minimumPaymentField.textField.text?.replacingOccurrences(of: ",", with: "") ?? ""
        if let payment = Decimal(string: minPaymentText), payment >= 0 {
            minimumPayment = NSDecimalNumber(decimal: payment).doubleValue
        } else {
            minimumPayment = 0
        }

        let dueDate: Date? = hasDueDateSwitch.isOn ? dueDatePicker.date : nil

        let notes = notesField.textField.text ?? ""

        // Handle edit vs add
        if let existingLiability = liabilityToEdit {
            viewModel.updateLiability(existingLiability,
                                     name: name,
                                     type: type,
                                     balance: balanceDouble,
                                     interestRate: interestRate,
                                     minimumPayment: minimumPayment,
                                     dueDate: dueDate,
                                     notes: notes)
        } else {
            let liability = Liability()
            liability.name = name
            liability.type = type
            liability.balance = balanceDouble
            liability.interestRate = interestRate
            liability.minimumPayment = minimumPayment
            liability.dueDate = dueDate
            liability.notes = notes

            viewModel.addLiability(liability)
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

extension AddLiabilityViewController: UITextFieldDelegate {
    // Allow editing to proceed as normal
}
