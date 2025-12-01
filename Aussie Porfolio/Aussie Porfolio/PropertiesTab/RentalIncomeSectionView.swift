import UIKit
import SnapKit

/// Simple reusable view to capture rental income and related costs.
final class RentalIncomeSectionView: UIView {
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Rental Income"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let weeklyIncomeNoteLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter weekly rent only"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
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
        LabeledField(title: "Other Property Expenses ($/year)",
                     placeholder: "Optional",
                     keyboard: .numberPad)
    }()

    private let annualSummaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private var purchasePrice: Double?
    private var monthlyLoanRepayment: Double?
    var onChange: (() -> Void)?

    private lazy var helperButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        b.tintColor = .secondaryLabel
        b.addTarget(self, action: #selector(showHelperAnnualCosts), for: .touchUpInside)
        return b
    }()

    init() {
        super.init(frame: .zero)
        build()
        weeklyIncomeField.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        managementFeeField.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        expensesAmountField.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        updateAnnualSummary()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build() {
        let headerRow = UIStackView(arrangedSubviews: [headerLabel, helperButton])
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.spacing = 8

        let stack = UIStackView(arrangedSubviews: [headerRow, weeklyIncomeField, weeklyIncomeNoteLabel, managementFeeField, expensesAmountField, annualSummaryLabel])
        stack.axis = .vertical
        stack.spacing = 8
        addSubview(stack)

        helperButton.snp.makeConstraints { make in
            make.size.equalTo(22)
        }

        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setValues(weeklyIncome: Double, managementFeePercent: Double, expensesAmount: Double, expensesFrequencyMonthly: Bool) {
        weeklyIncomeField.textField.text = weeklyIncome > 0 ? Int(weeklyIncome).formattedWithSeparator() : ""
        managementFeeField.textField.text = managementFeePercent > 0 ? String(format: "%.2f", managementFeePercent) : ""
        let annualizedExpenses = expensesFrequencyMonthly ? expensesAmount * 12 : expensesAmount
        expensesAmountField.textField.text = annualizedExpenses > 0 ? Int(annualizedExpenses).formattedWithSeparator() : ""
        updateAnnualSummary()
    }

    /// Update contextual values used in the summary (purchase price and loan repayment).
    func updateFinancialContext(purchasePrice: Double?, monthlyLoanRepayment: Double?) {
        self.purchasePrice = purchasePrice
        self.monthlyLoanRepayment = monthlyLoanRepayment
        updateAnnualSummary()
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
        // Field is labelled $/year, so treat as annual.
        return (amt, false)
    }

    @objc private func textDidChange() {
        updateAnnualSummary()
        onChange?()
    }

    private func updateAnnualSummary() {
        let weeklyIncome = parsedWeeklyIncome()
        let annualIncome = weeklyIncome * 52

        let managementPercent = parsedManagementFeePercent()
        let expenses = parsedExpenses()

        let annualMgmt = (managementPercent / 100) * annualIncome
        let annualLoan = (monthlyLoanRepayment ?? 0) * 12
        let annualBase = expenses.isMonthly ? expenses.amount * 12 : expenses.amount
        let totalCosts = annualBase + annualMgmt + annualLoan
        let net = annualIncome - totalCosts

        let effectivePurchase = purchasePrice ?? 0
        let grossYieldText: String
        if effectivePurchase > 0 {
            let yield = annualIncome / effectivePurchase * 100
            grossYieldText = String(format: "%.2f%% gross yield", yield)
        } else {
            grossYieldText = "-- gross yield"
        }

        let attributed = NSMutableAttributedString(
            string: "Annual Income: $\(Int(annualIncome).formattedWithSeparator())\n",
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        )
        attributed.append(NSAttributedString(
            string: "\(grossYieldText)\n",
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        ))
        attributed.append(NSAttributedString(
            string: "Net: $\(Int(net).formattedWithSeparator())",
            attributes: [.foregroundColor: net >= 0 ? UIColor.systemGreen : UIColor.systemRed]
        ))

        annualSummaryLabel.attributedText = attributed
    }

    @objc private func showHelperAnnualCosts() {
        let message = """
Typical Australian house expenses (council, water, insurance, maintenance) often total $7,500 – $12,600 Anually. Use this as a guide and adjust for your property.
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
