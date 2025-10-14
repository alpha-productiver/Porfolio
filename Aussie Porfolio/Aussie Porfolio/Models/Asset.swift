import Foundation
import RealmSwift

class Asset: Object {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var name: String = ""
    @Persisted var type: String = "shares"
    @Persisted var value: Double = 0.0
    @Persisted var quantity: Double = 0.0
    @Persisted var purchasePrice: Double = 0.0
    @Persisted var notes: String = ""
    @Persisted var createdAt = Date()
    @Persisted var updatedAt = Date()
    
    var gainLoss: Double {
        return value - purchasePrice
    }

    var gainLossPercentage: Double {
        guard purchasePrice > 0 else { return 0 }
        return ((value - purchasePrice) / purchasePrice) * 100
    }
}

// MARK: - AssetCardData Conformance

extension Asset: AssetCardData {
    var cardTitle: String {
        return name
    }

    var cardSubtitle: String {
        return type.capitalized
    }

    var cardValue: String {
        return "$\(Int(value).formattedWithSeparator())"
    }

    var cardDetail: String {
        let gain = gainLoss
        let sign = gain >= 0 ? "+" : ""
        return "Gain/Loss: \(sign)$\(Int(abs(gain)).formattedWithSeparator())"
    }
}
