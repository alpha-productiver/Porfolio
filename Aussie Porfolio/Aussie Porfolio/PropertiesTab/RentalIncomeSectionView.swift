import UIKit

/// Simple reusable view to capture rental income and related costs.
final class RentalIncomeSectionView: UIView {
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Rental Income & Costs"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        return label
    }()

    let weeklyIncomeField: LabeledField = {
        LabeledField(title: "Weekly Rental Income ($)",
                     placeholder: "e.g. 600",
                     keyboard: .numberPad)
    }()

    let managementFeeField: LabeledField = {
        LabeledField(title: "Management Fee (%)",
                     placeholder: "Optional",
                     keyboard: .decimalPad)
    }()

    let expensesAmountField: LabeledField = {
        LabeledField(title: "Property Expenses ($)",
                     placeholder: "Optional",
                     keyboard: .numberPad)
    }()

    let expensesFrequencyControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Monthly", "Yearly"])
        control.selectedSegmentIndex = 0
        return control
    }()

    private lazy var helperButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        b.tintColor = .secondaryLabel
        b.addTarget(self, action: #selector(showHelper), for: .touchUpInside)
        b.widthAnchor.constraint(equalToConstant: 22).isActive = true
        b.heightAnchor.constraint(equalToConstant: 22).isActive = true
        return b
    }()

    init() {
        super.init(frame: .zero)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build() {
        let freqRow = UIStackView(arrangedSubviews: [expensesAmountField, expensesFrequencyControl])
        freqRow.axis = .horizontal
        freqRow.spacing = 12
        freqRow.distribution = .fillProportionally
        expensesAmountField.widthAnchor.constraint(equalTo: freqRow.widthAnchor, multiplier: 0.55).isActive = true

        let headerRow = UIStackView(arrangedSubviews: [headerLabel, helperButton])
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.spacing = 8

        let stack = UIStackView(arrangedSubviews: [headerRow, weeklyIncomeField, managementFeeField, freqRow])
        stack.axis = .vertical
        stack.spacing = 8
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func setValues(weeklyIncome: Double, managementFeePercent: Double, expensesAmount: Double, expensesFrequencyMonthly: Bool) {
        weeklyIncomeField.textField.text = weeklyIncome > 0 ? Int(weeklyIncome).formattedWithSeparator() : ""
        managementFeeField.textField.text = managementFeePercent > 0 ? String(format: "%.2f", managementFeePercent) : ""
        expensesAmountField.textField.text = expensesAmount > 0 ? Int(expensesAmount).formattedWithSeparator() : ""
        expensesFrequencyControl.selectedSegmentIndex = expensesFrequencyMonthly ? 0 : 1
    }

    func parsedWeeklyIncome() -> Double {
        let raw = weeklyIncomeField.textField.text?.replacingOccurrences(of: ",", with: "") ?? ""
        return Double(raw) ?? 0
    }

    func parsedManagementFeePercent() -> Double {
        let raw = managementFeeField.textField.text?.replacingOccurrences(of: ",", with: "") ?? ""
        return Double(raw) ?? 0
    }

    func parsedExpenses() -> (amount: Double, isMonthly: Bool) {
        let raw = expensesAmountField.textField.text?.replacingOccurrences(of: ",", with: "") ?? ""
        let amt = Double(raw) ?? 0
        let monthly = expensesFrequencyControl.selectedSegmentIndex == 0
        return (amt, monthly)
    }

    @objc private func showHelper() {
        let message = """
Typical Australian house expenses (council, water, insurance, maintenance) often total $400–$600 per month. Use this as a guide and adjust for your property.
"""
        let alert = UIAlertController(title: "Expense Guide", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
        parentViewController?.present(alert, animated: true)
    }
}

// Helper to find parent view controller
private extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController { return vc }
            responder = responder?.next
        }
        return nil
    }
}
