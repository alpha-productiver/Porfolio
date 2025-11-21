import Foundation
import RealmSwift
internal import Realm


// MARK: - ViewModel

final class CashFlowViewModel {
    // MARK: - Output
    private(set) var totalIncomeText: String = "$0"
    private(set) var totalExpensesText: String = "$0"
    private(set) var netCashFlowText: String = "$0"
    private(set) var isNetPositive: Bool = true
    private(set) var propertyItems: [CashFlowPropertyItem] = []

    var onDataChanged: (() -> Void)?

    // MARK: - Internals
    private let realmService: RealmService
    private var notificationTokens: [NotificationToken] = []

    private var properties: [Property] = [] { didSet { recalculate() } }
    private var liabilities: [Liability] = [] { didSet { recalculate() } }

    // MARK: - Init
    init(realmService: RealmService = .shared) {
        self.realmService = realmService
        load()
        observe()
    }

    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }

    // MARK: - Data
    private func load() {
        properties = realmService.fetch(Property.self)
        liabilities = realmService.fetch(Liability.self)
        recalculate()
    }

    private func observe() {
        let realm = realmService.realm

        let propertyToken = realm.objects(Property.self).observe { [weak self] _ in
            self?.properties = self?.realmService.fetch(Property.self) ?? []
        }

        let liabilityToken = realm.objects(Liability.self).observe { [weak self] _ in
            self?.liabilities = self?.realmService.fetch(Liability.self) ?? []
        }

        notificationTokens = [propertyToken, liabilityToken]
    }

    // MARK: - Calculations
    private func recalculate() {
        let totalIncome = properties.reduce(0) { $0 + $1.rentalIncome }

        let propertyExpenses = properties.reduce(0) { total, property in
            let mortgage = property.loan?.monthlyRepayment ?? 0
            let insurance = monthlyInsurance(for: property)
            return total + property.expenses + mortgage + insurance
        }

        let liabilityPayments = liabilities.reduce(0) { $0 + max($1.minimumPayment, 0) }
        let totalExpenses = propertyExpenses + liabilityPayments
        let net = totalIncome - totalExpenses

        totalIncomeText = formatCurrency(totalIncome)
        totalExpensesText = formatCurrency(totalExpenses)
        netCashFlowText = formatCurrency(net)
        isNetPositive = net >= 0

        propertyItems = properties.map { property in
            let mortgage = property.loan?.monthlyRepayment ?? 0
            let insurance = monthlyInsurance(for: property)
            let income = property.rentalIncome
            let expenses = property.expenses + mortgage + insurance
            let netValue = income - expenses

            return CashFlowPropertyItem(
                name: property.name.isEmpty ? "Property" : property.name,
                tag: tag(for: property),
                iconSystemName: iconSystemName(for: property.propertyType),
                incomeText: formatCurrency(income),
                expensesText: formatCurrency(expenses),
                netText: formatCurrency(netValue),
                netIsPositive: netValue >= 0,
                nextPaymentText: nextPaymentText(for: property, mortgage: mortgage, insurance: insurance)
            )
        }

        onDataChanged?()
    }

    private func monthlyInsurance(for property: Property) -> Double {
        guard let insurance = property.insurance else { return 0 }
        return insurance.buildingMonthlyRepayment + insurance.landlordMonthlyRepayment
    }

    private func nextPaymentText(for property: Property, mortgage: Double, insurance: Double) -> String {
        if mortgage > 0 {
            return "Mortgage: \(formatCurrency(mortgage))"
        }
        if insurance > 0 {
            return "Insurance: \(formatCurrency(insurance))"
        }
        return "No upcoming payment"
    }

    private func iconSystemName(for propertyType: String) -> String {
        switch propertyType.lowercased() {
        case "unit", "apartment": return "building.2.fill"
        case "townhouse": return "house.lodge.fill"
        case "house": return "house.fill"
        default: return "building.2"
        }
    }

    private func tag(for property: Property) -> String {
        // Map to the two tags used in the SwiftUI design: IP (investment) or PPOR (principal place of residence)
        let type = property.propertyType.lowercased()
        if type == "ppor" || type == "home" || type == "residence" {
            return "PPOR"
        }
        return "IP"
    }

    private func formatCurrency(_ value: Double) -> String {
        let sign = value < 0 ? "-" : ""
        let formatted = Int(abs(value)).formattedWithSeparator()
        return "\(sign)$\(formatted)"
    }
}
