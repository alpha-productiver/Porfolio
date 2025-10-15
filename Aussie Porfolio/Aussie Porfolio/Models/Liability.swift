import Foundation
import RealmSwift
import UIKit

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
        var parts: [String] = []

        if let dueDate = dueDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            parts.append("Due: \(formatter.string(from: dueDate))")
        }

        if interestRate > 0 {
            parts.append("Interest Rate: \(String(format: "%.2f", interestRate))%")
        }

        return parts.isEmpty ? "No details" : parts.joined(separator: " • ")
    }

    var cardDetailAttributedString: NSAttributedString? {
        let attributedString = NSMutableAttributedString()
        var hasContent = false

        // Add due date if available
        if let dueDate = dueDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium

            attributedString.append(NSAttributedString(
                string: "Due: ",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.secondaryLabel
                ]
            ))

            attributedString.append(NSAttributedString(
                string: formatter.string(from: dueDate),
                attributes: [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.label
                ]
            ))

            hasContent = true
        }

        // Add interest rate if available
        if interestRate > 0 {
            if hasContent {
                attributedString.append(NSAttributedString(
                    string: " • ",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 12),
                        .foregroundColor: UIColor.secondaryLabel
                    ]
                ))
            }

            let rateText = "\(String(format: "%.2f", interestRate))%"

            attributedString.append(NSAttributedString(
                string: "Interest Rate: ",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.secondaryLabel
                ]
            ))

            attributedString.append(NSAttributedString(
                string: rateText,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.systemRed
                ]
            ))

            hasContent = true
        }

        return hasContent ? attributedString : nil
    }

    var cardValueColor: UIColor {
        return .systemRed
    }

    var cardDetailColor: UIColor {
        return .secondaryLabel
    }
}
