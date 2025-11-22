import Foundation
import RealmSwift
internal import Realm

struct CashFlowPropertyItem {
    let id: String
    let name: String
    let tag: String
    let iconSystemName: String
    let incomeText: String
    let expensesText: String
    let netText: String
    let netIsPositive: Bool
    let nextPaymentText: String
}

struct CashFlowLiabilityItem {
    let id: String
    let name: String
    let type: String
    let balanceText: String
    let paymentText: String
    let dueText: String
}

struct CashFlowChartEntry {
    let title: String
    let amount: Double
    let normalized: CGFloat
}


// MARK: - ViewModel

final class CashFlowViewModel {
    // MARK: - Output
    private(set) var totalIncomeText: String = "$0"
    private(set) var totalExpensesText: String = "$0"
    private(set) var netCashFlowText: String = "$0"
    private(set) var isNetPositive: Bool = true
    private(set) var annualIncomeText: String = "$0"
    private(set) var annualExpensesText: String = "$0"
    private(set) var annualNetText: String = "$0"
    private(set) var isAnnualNetPositive: Bool = true
    private(set) var propertyItems: [CashFlowPropertyItem] = []
    private(set) var liabilityItems: [CashFlowLiabilityItem] = []
    private(set) var normalizedTrendPoints: [CGFloat] = [0.5, 0.5, 0.5]
    private(set) var chartEntries: [CashFlowChartEntry] = []
    private(set) var expensesBreakdownText: String = ""
    private(set) var chartTitles: [String] = ["Income", "Expenses", "Net"]

    var onDataChanged: (() -> Void)?

    // MARK: - Internals
    private let realmService: RealmService
    private var notificationTokens: [NotificationToken] = []

    private var properties: [Property] = [] { didSet { recalculate() } }
    private var liabilities: [Liability] = [] { didSet { recalculate() } }
    private var totalIncomeRaw: Double = 0
    private var totalExpensesRaw: Double = 0
    private var netRaw: Double = 0

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

        totalIncomeRaw = totalIncome
        totalExpensesRaw = totalExpenses
        netRaw = net

        totalIncomeText = formatCurrency(totalIncome)
        totalExpensesText = formatCurrency(totalExpenses)
        netCashFlowText = formatCurrency(net)
        isNetPositive = net >= 0
        annualIncomeText = formatCurrency(totalIncome * 12)
        annualExpensesText = formatCurrency(totalExpenses * 12)
        let annualNet = net * 12
        annualNetText = formatCurrency(annualNet)
        isAnnualNetPositive = annualNet >= 0

        propertyItems = properties.map { property in
            let mortgage = property.loan?.monthlyRepayment ?? 0
            let insurance = monthlyInsurance(for: property)
            let income = property.rentalIncome
            let expenses = property.expenses + mortgage + insurance
            let netValue = income - expenses

            return CashFlowPropertyItem(
                id: property.id,
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

        liabilityItems = liabilities.map { liability in
            CashFlowLiabilityItem(
                id: liability.id,
                name: liability.name.isEmpty ? "Liability" : liability.name,
                type: liability.type.capitalized,
                balanceText: formatCurrency(liability.balance),
                paymentText: liability.minimumPayment > 0 ? "Min payment: \(formatCurrency(liability.minimumPayment))" : "No min payment",
                dueText: dueText(for: liability.dueDate)
            )
        }

        normalizedTrendPoints = makeTrendPoints(income: totalIncomeRaw, expenses: totalExpensesRaw, net: netRaw)
        chartEntries = makeChartEntries(income: totalIncome, expenses: totalExpenses, net: net)
        expensesBreakdownText = buildExpensesBreakdown(propertyExpenses: propertyExpenses, liabilityPayments: liabilityPayments)

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

    private func dueText(for date: Date?) -> String {
        guard let date else { return "No due date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "Due \(formatter.string(from: date))"
    }

    func property(withId id: String) -> Property? {
        properties.first { $0.id == id }
    }

    func liability(withId id: String) -> Liability? {
        liabilities.first { $0.id == id }
    }

    private func makeTrendPoints(income: Double, expenses: Double, net: Double) -> [CGFloat] {
        let maxMagnitude = max(abs(income), abs(expenses), abs(net))
        let safeMax = maxMagnitude.isFinite && maxMagnitude > 0 ? maxMagnitude : 1
        let incomePoint = min(max(income / safeMax, 0), 1)
        let expensesPoint = min(max(expenses / safeMax, 0), 1)
        let netPoint = (CGFloat(net / safeMax) + 1) / 2 // shift to 0...1
        return [CGFloat(incomePoint), CGFloat(expensesPoint), netPoint]
    }

    private func makeChartEntries(income: Double, expenses: Double, net: Double) -> [CashFlowChartEntry] {
        let points = makeTrendPoints(income: income, expenses: expenses, net: net)
        let titles = ["Income", "Expenses", "Net"]
        let amounts = [income, expenses, net]
        return zip(zip(titles, amounts), points).map { pair, normalized in
            CashFlowChartEntry(title: pair.0, amount: pair.1, normalized: normalized)
        }
    }

    private func buildExpensesBreakdown(propertyExpenses: Double, liabilityPayments: Double) -> String {
        let opex = formatCurrency(propertyExpenses - liabilitiesOnly(propertyExpenses: propertyExpenses, liabilityPayments: liabilityPayments))
        let loans = formatCurrency(properties.reduce(0) { $0 + ($1.loan?.monthlyRepayment ?? 0) })
        let insurance = formatCurrency(properties.reduce(0) { $0 + monthlyInsurance(for: $1) })
        let liabilitiesText = formatCurrency(liabilityPayments)
        return "Expenses: Opex \(opex) • Loans \(loans) • Insurance \(insurance) • Liabilities \(liabilitiesText)"
    }

    private func liabilitiesOnly(propertyExpenses: Double, liabilityPayments: Double) -> Double {
        // propertyExpenses already includes liabilities? We only need to subtract liabilities to avoid double counting in breakdown formatting
        return liabilityPayments
    }
}
