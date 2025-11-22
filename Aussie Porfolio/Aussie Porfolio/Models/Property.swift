import Foundation
import RealmSwift
import UIKit

class Property: Object {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var name: String = ""
    @Persisted var address: String = ""
    @Persisted var suburb: String = ""
    @Persisted var state: String = ""
    @Persisted var postcode: String = ""
    @Persisted var propertyType: String = "house"
    @Persisted var currentValue: Double = 0.0
    @Persisted var purchasePrice: Double = 0.0
    @Persisted var rentalIncome: Double = 0.0 // weekly
    @Persisted var managementFeePercent: Double = 0.0
    @Persisted var estimatedExpensesAmount: Double = 0.0
    @Persisted var expensesAreMonthly: Bool = true
    @Persisted var loan: PropertyLoan?
    @Persisted var insurance: PropertyInsurance?
    @Persisted var createdAt = Date()
    @Persisted var updatedAt = Date()

    var totalCostBase: Double {
        return purchasePrice
    }

    var equity: Double {
        return currentValue - (loan?.amount ?? 0)
    }

    var netRentalIncome: Double {
        let weeklyNet = rentalIncome - weeklyExpenses
        return weeklyNet
    }

    var weeklyExpenses: Double {
        let base = expensesAreMonthly ? (estimatedExpensesAmount * 12 / 52) : (estimatedExpensesAmount / 52)
        let management = (managementFeePercent / 100) * rentalIncome
        return base + management
    }
}

class PropertyLoan: Object {
    @Persisted var amount: Double = 0.0
    @Persisted var interestRate: Double = 0.0
    @Persisted var loanType: String = "variable"
    @Persisted var monthlyRepayment: Double = 0.0
    @Persisted var repaymentFrequencyPerYear: Int = 12
    @Persisted var customPaymentPerPeriod: Double = 0.0
    @Persisted var usesManualRepayment: Bool = false

    var annualInterest: Double {
        return amount * (interestRate / 100)
    }
}

class PropertyInsurance: Object {
    // Building Insurance
    @Persisted var buildingProvider: String = ""
    @Persisted var buildingFrequency: String = "Monthly" // "Monthly" or "Yearly"
    @Persisted var buildingAmount: Double = 0.0
    @Persisted var buildingRenewalDate: Date?

    // Landlord Insurance
    @Persisted var landlordProvider: String = ""
    @Persisted var landlordFrequency: String = "Monthly" // "Monthly" or "Yearly"
    @Persisted var landlordAmount: Double = 0.0
    @Persisted var landlordRenewalDate: Date?

    // Same provider flag
    @Persisted var sameProvider: Bool = false

    var buildingYearlyRepayment: Double {
        if buildingFrequency == "Yearly" {
            return buildingAmount
        } else if buildingFrequency == "Fortnightly" {
            return buildingAmount * 26
        } else {
            return buildingAmount * 12
        }
    }

    var buildingMonthlyRepayment: Double {
        if buildingFrequency == "Monthly" {
            return buildingAmount
        } else if buildingFrequency == "Fortnightly" {
            return (buildingAmount * 26) / 12
        } else {
            return buildingAmount / 12
        }
    }

    var landlordYearlyRepayment: Double {
        if landlordFrequency == "Yearly" {
            return landlordAmount
        } else if landlordFrequency == "Fortnightly" {
            return landlordAmount * 26
        } else {
            return landlordAmount * 12
        }
    }

    var landlordMonthlyRepayment: Double {
        if landlordFrequency == "Monthly" {
            return landlordAmount
        } else if landlordFrequency == "Fortnightly" {
            return (landlordAmount * 26) / 12
        } else {
            return landlordAmount / 12
        }
    }

    var totalYearlyRepayment: Double {
        return buildingYearlyRepayment + landlordYearlyRepayment
    }
}

// MARK: - AssetCardData Conformance

extension Property: AssetCardData {
    var cardTitle: String {
        return name
    }

    var cardSubtitle: String {
        let components = [suburb.trimmingCharacters(in: .whitespaces),
                         state.trimmingCharacters(in: .whitespaces),
                         postcode.trimmingCharacters(in: .whitespaces)]
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }

    var cardValue: String {
        return "$\(Int(currentValue).formattedWithSeparator())"
    }

    var cardDetail: String {
        return "Equity: $\(Int(equity).formattedWithSeparator())"
    }

    var cardDetailAttributedString: NSAttributedString? {
        let equityText = "$\(Int(equity).formattedWithSeparator())"

        let attributedString = NSMutableAttributedString(
            string: "Equity: ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )

        attributedString.append(NSAttributedString(
            string: equityText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.systemGreen
            ]
        ))

        return attributedString
    }

    var cardValueColor: UIColor {
        return .systemBlue
    }

    var cardDetailColor: UIColor {
        return .secondaryLabel
    }
}
