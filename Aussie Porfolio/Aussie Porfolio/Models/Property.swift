import Foundation
import RealmSwift

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
    @Persisted var rentalIncome: Double = 0.0
    @Persisted var expenses: Double = 0.0
    @Persisted var loan: PropertyLoan?
    @Persisted var createdAt = Date()
    @Persisted var updatedAt = Date()

    var totalCostBase: Double {
        return purchasePrice
    }

    var equity: Double {
        return currentValue - (loan?.amount ?? 0)
    }

    var netRentalIncome: Double {
        return rentalIncome - expenses
    }
}

class PropertyLoan: Object {
    @Persisted var amount: Double = 0.0
    @Persisted var interestRate: Double = 0.0
    @Persisted var loanType: String = "variable"
    @Persisted var monthlyRepayment: Double = 0.0

    var annualInterest: Double {
        return amount * (interestRate / 100)
    }
}

// MARK: - AssetCardData Conformance

extension Property: AssetCardData {
    var cardTitle: String {
        return name
    }

    var cardSubtitle: String {
        return "\(suburb) \(state) \(postcode)"
    }

    var cardValue: String {
        return "$\(Int(currentValue).formattedWithSeparator())"
    }

    var cardDetail: String {
        return "Equity: $\(Int(equity).formattedWithSeparator())"
    }
}
