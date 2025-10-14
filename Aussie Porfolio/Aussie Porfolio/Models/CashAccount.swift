import Foundation
import RealmSwift

class CashAccount: Object {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var name: String = ""
    @Persisted var accountType: String = "savings"
    @Persisted var balance: Double = 0.0
    @Persisted var interestRate: Double = 0.0
    @Persisted var institution: String = ""
    @Persisted var notes: String = ""
    @Persisted var createdAt = Date()
    @Persisted var updatedAt = Date()
    
    var annualInterest: Double {
        return balance * (interestRate / 100)
    }
}

// MARK: - AssetCardData Conformance

extension CashAccount: AssetCardData {
    var cardTitle: String {
        return name
    }

    var cardSubtitle: String {
        return "\(accountType.capitalized) • \(institution)"
    }

    var cardValue: String {
        return "$\(Int(balance).formattedWithSeparator())"
    }

    var cardDetail: String {
        if interestRate > 0 {
            return "Interest Rate: \(String(format: "%.2f", interestRate))%"
        } else {
            return "No interest"
        }
    }
}
