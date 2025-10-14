import Foundation
import RealmSwift

class Liability: Object {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var name: String = ""
    @Persisted var type: String = "loan"
    @Persisted var balance: Double = 0.0
    @Persisted var interestRate: Double = 0.0
    @Persisted var minimumPayment: Double = 0.0
    @Persisted var dueDate: Date?
    @Persisted var notes: String = ""
    @Persisted var createdAt = Date()
    @Persisted var updatedAt = Date()
    
    var annualInterestCost: Double {
        return balance * (interestRate / 100)
    }
}

// MARK: - AssetCardData Conformance

extension Liability: AssetCardData {
    var cardTitle: String {
        return name
    }

    var cardSubtitle: String {
        return type.capitalized
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
