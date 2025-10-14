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
