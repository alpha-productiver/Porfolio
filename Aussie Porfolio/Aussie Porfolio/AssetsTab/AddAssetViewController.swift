import UIKit

final class AddAssetViewController: UIViewController {

    weak var coordinator: MainCoordinator?
    private let viewModel: AssetViewModel
    private let assetToEdit: Asset?

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // Asset details
    private let nameField = LabeledField(title: "Asset Name",
                                         placeholder: "e.g., Apple Shares, Bitcoin")
    private let typeField = LabeledField(title: "Asset Type",
                                         placeholder: "e.g., Shares, Crypto, Bonds")

    // Financial details
    private let valueField = LabeledField(title: "Current Value ($)",
                                          placeholder: "50,000",
                                          keyboard: .numberPad)
    private let quantityField = LabeledField(title: "Quantity (optional)",
                                             placeholder: "100",
                                             keyboard: .decimalPad)
    private let purchasePriceField = LabeledField(title: "Purchase Price ($)",
                                                   placeholder: "40,000",
                                                   keyboard: .numberPad)
    private let notesField = LabeledField(title: "Notes (optional)",
                                          placeholder: "Additional information")

    // MARK: - Init
    init(viewModel: AssetViewModel, assetToEdit: Asset? = nil) {
        self.viewModel = viewModel
        self.assetToEdit = assetToEdit
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = assetToEdit == nil ? "Add Asset" : "Edit Asset"
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

        // Asset Details
        contentStack.addArrangedSubview(FormSectionHeader("Asset Details"))
        contentStack.addArrangedSubview(nameField)
        contentStack.addArrangedSubview(typeField)

        contentStack.addArrangedSubview(Divider())

        // Financial Details
        contentStack.addArrangedSubview(FormSectionHeader("Financial Details"))
        contentStack.addArrangedSubview(valueField)
        contentStack.addArrangedSubview(quantityField)
        contentStack.addArrangedSubview(purchasePriceField)

        contentStack.addArrangedSubview(Divider())

        // Notes
        contentStack.addArrangedSubview(FormSectionHeader("Additional Information"))
        contentStack.addArrangedSubview(notesField)
    }

    // Add "Done" toolbar for number pads
    private func addDoneToolbarToKeyboards() {
        [valueField.textField,
         quantityField.textField,
         purchasePriceField.textField].forEach { tf in
            let tb = UIToolbar()
            tb.sizeToFit()
            let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: tf, action: #selector(UIView.endEditing(_:)))
            tb.items = [flex, done]
            tf.inputAccessoryView = tb
        }

        // Set delegate for currency fields to add comma formatting
        valueField.textField.delegate = self
        valueField.textField.addTarget(self, action: #selector(currencyFieldDidChange(_:)), for: .editingChanged)
        purchasePriceField.textField.delegate = self
        purchasePriceField.textField.addTarget(self, action: #selector(currencyFieldDidChange(_:)), for: .editingChanged)
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
        guard let asset = assetToEdit else { return }

        nameField.textField.text = asset.name
        typeField.textField.text = asset.type
        valueField.textField.text = Int(asset.value).formattedWithSeparator()
        quantityField.textField.text = asset.quantity > 0 ? "\(asset.quantity)" : ""
        purchasePriceField.textField.text = Int(asset.purchasePrice).formattedWithSeparator()
        notesField.textField.text = asset.notes
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        // Basic validation
        guard let name = nameField.textField.text, !name.isEmpty else {
            showAlert("Please enter an asset name."); return
        }
        guard let type = typeField.textField.text, !type.isEmpty else {
            showAlert("Please enter an asset type."); return
        }

        // Strip commas before parsing
        let valueText = valueField.textField.text?.replacingOccurrences(of: ",", with: "") ?? ""
        guard let value = Decimal(string: valueText), value > 0 else {
            showAlert("Please enter a valid current value."); return
        }

        let purchasePriceText = purchasePriceField.textField.text?.replacingOccurrences(of: ",", with: "") ?? ""
        guard let purchasePrice = Decimal(string: purchasePriceText), purchasePrice > 0 else {
            showAlert("Please enter a valid purchase price."); return
        }

        let valueDouble = NSDecimalNumber(decimal: value).doubleValue
        let purchasePriceDouble = NSDecimalNumber(decimal: purchasePrice).doubleValue

        let quantity: Double
        if let quantityText = quantityField.textField.text, !quantityText.isEmpty,
           let qty = Double(quantityText) {
            quantity = qty
        } else {
            quantity = 0
        }

        let notes = notesField.textField.text ?? ""

        // Handle edit vs add
        if let existingAsset = assetToEdit {
            viewModel.updateAsset(existingAsset,
                                 name: name,
                                 type: type,
                                 value: valueDouble,
                                 quantity: quantity,
                                 purchasePrice: purchasePriceDouble,
                                 notes: notes)
        } else {
            let asset = Asset()
            asset.name = name
            asset.type = type
            asset.value = valueDouble
            asset.quantity = quantity
            asset.purchasePrice = purchasePriceDouble
            asset.notes = notes

            viewModel.addAsset(asset)
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

extension AddAssetViewController: UITextFieldDelegate {
    // Allow editing to proceed as normal
}
