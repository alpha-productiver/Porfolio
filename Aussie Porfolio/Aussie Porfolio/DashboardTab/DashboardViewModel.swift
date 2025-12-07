import Foundation
import RealmSwift
internal import Realm

class DashboardViewModel {
    var properties: [Property] = [] {
        didSet { calculateTotals(); onDataChanged?() }
    }
    var assets: [Asset] = [] {
        didSet { calculateTotals(); onDataChanged?() }
    }
    var cashAccounts: [CashAccount] = [] {
        didSet { calculateTotals(); onDataChanged?() }
    }
    var liabilities: [Liability] = [] {
        didSet { calculateTotals(); onDataChanged?() }
    }

    // MARK: - Display Properties (formatted for UI)
    var portfolioValueText: String = ""
    var portfolioSubtitleText: String = ""
    var netWorthText: String = ""
    var netWorthSubtitleText: String = ""
    var liabilitiesText: String = ""
    var liabilitiesSubtitleText: String = ""
    var monthlyCashflowText: String = ""
    var monthlyCashflowSubtitleText: String = ""
    var annualCashflowText: String = ""
    var annualCashflowSubtitleText: String = ""
    var monthlyCashflowIsPositive: Bool = true
    var annualCashflowIsPositive: Bool = true
    var propertiesValueText: String = ""
    var propertiesCountText: String = ""
    var assetsValueText: String = ""
    var assetsCountText: String = ""
    var cashValueText: String = ""
    var cashCountText: String = ""
    var allocationPercentageText: String = ""
    var allocationSubtitleText: String = "in property"

    // LVR Card
    var lvrPercentage: Double = 0
    var lvrAssetText: String = ""
    var lvrDebtText: String = ""

    var onDataChanged: (() -> Void)?

    // MARK: - Private Properties
    private var totalPortfolioValue: Double = 0
    private var netWorth: Double = 0
    private var totalPropertyValue: Double = 0
    private var totalAssetValue: Double = 0
    private var totalCashValue: Double = 0
    private var totalLiabilities: Double = 0
    private var totalPropertyLoans: Double = 0

    private var monthlyIncomeTotal: Double = 0
    private var monthlyExpenseTotal: Double = 0
    private var monthlyNetTotal: Double = 0
    private var annualNetTotal: Double = 0

    private let realmService: RealmService
    private var notificationTokens: [NotificationToken] = []

    init(realmService: RealmService = .shared) {
        self.realmService = realmService
        loadData()
    }

    func loadData() {
        properties = realmService.fetch(Property.self)
        assets = realmService.fetch(Asset.self)
        cashAccounts = realmService.fetch(CashAccount.self)
        liabilities = realmService.fetch(Liability.self)

        calculateTotals()
        observeChanges()
    }

    private func observeChanges() {
        let realm = realmService.realm

        let propertiesToken = realm.objects(Property.self).observe { [weak self] _ in
            self?.properties = self?.realmService.fetch(Property.self) ?? []
        }

        let assetsToken = realm.objects(Asset.self).observe { [weak self] _ in
            self?.assets = self?.realmService.fetch(Asset.self) ?? []
        }

        let cashToken = realm.objects(CashAccount.self).observe { [weak self] _ in
            self?.cashAccounts = self?.realmService.fetch(CashAccount.self) ?? []
        }

        let liabilitiesToken = realm.objects(Liability.self).observe { [weak self] _ in
            self?.liabilities = self?.realmService.fetch(Liability.self) ?? []
        }

        notificationTokens = [propertiesToken, assetsToken, cashToken, liabilitiesToken]
    }

    private func calculateTotals() {
        // Calculate raw values
        totalPropertyValue = properties.reduce(0) { $0 + $1.currentValue }
        totalAssetValue = assets.reduce(0) { $0 + $1.value }
        totalCashValue = cashAccounts.reduce(0) { $0 + $1.balance }

        // Total liabilities = standalone liabilities + property mortgages
        let standaloneLiabilities = liabilities.reduce(0) { $0 + $1.balance }
        totalPropertyLoans = properties.reduce(0) { $0 + ($1.loan?.amount ?? 0) }
        totalLiabilities = standaloneLiabilities + totalPropertyLoans

        totalPortfolioValue = totalPropertyValue + totalAssetValue + totalCashValue
        netWorth = totalPortfolioValue - totalLiabilities

        // Cashflow
        calculateCashflow()

        // Format for display
        updateDisplayProperties()
    }

    private func updateDisplayProperties() {
        // Portfolio Value
        portfolioValueText = formatCurrency(totalPortfolioValue)
        portfolioSubtitleText = "Total asset value"

        // Net Worth
        netWorthText = formatCurrency(netWorth)
        netWorthSubtitleText = netWorth >= 0 ? "Positive net worth" : "Negative net worth"

        // Liabilities
        liabilitiesText = formatCurrency(totalLiabilities)
        let propertyLoansCount = properties.filter { $0.loan != nil }.count
        let standaloneLiabilitiesCount = liabilities.count

        if standaloneLiabilitiesCount == 0 && propertyLoansCount == 0 {
            liabilitiesSubtitleText = "No liabilities recorded"
        } else if standaloneLiabilitiesCount == 0 {
            liabilitiesSubtitleText = "\(propertyLoansCount) \(propertyLoansCount == 1 ? "mortgage" : "mortgages")"
        } else if propertyLoansCount == 0 {
            liabilitiesSubtitleText = "\(standaloneLiabilitiesCount) \(standaloneLiabilitiesCount == 1 ? "liability" : "liabilities")"
        } else {
            liabilitiesSubtitleText = "\(standaloneLiabilitiesCount) \(standaloneLiabilitiesCount == 1 ? "liability" : "liabilities") + \(propertyLoansCount) \(propertyLoansCount == 1 ? "mortgage" : "mortgages")"
        }

        // Properties
        propertiesValueText = formatCurrency(totalPropertyValue)
        propertiesCountText = "\(properties.count) \(properties.count == 1 ? "property" : "properties")"

        // Assets
        assetsValueText = formatCurrency(totalAssetValue)
        assetsCountText = "\(assets.count) \(assets.count == 1 ? "asset" : "assets")"

        // Cash
        cashValueText = formatCurrency(totalCashValue)
        cashCountText = "\(cashAccounts.count) \(cashAccounts.count == 1 ? "account" : "accounts")"

        // Allocation
        let percentage = totalPortfolioValue > 0 ? Int((totalPropertyValue / totalPortfolioValue) * 100) : 0
        allocationPercentageText = "\(percentage)%"

        // LVR (Loan to Value Ratio) - use stored totalPropertyLoans
        if totalPropertyValue > 0 {
            lvrPercentage = (totalPropertyLoans / totalPropertyValue) * 100
        } else {
            lvrPercentage = 0
        }
        lvrAssetText = formatCurrency(totalPropertyValue)
        lvrDebtText = formatCurrency(totalPropertyLoans)

        // Cashflow cards
        let monthlyNet = monthlyIncomeTotal - monthlyExpenseTotal
        monthlyNetTotal = monthlyNet
        monthlyCashflowText = formatCurrency(monthlyNet)
        monthlyCashflowSubtitleText = ""
        monthlyCashflowIsPositive = monthlyNet >= 0

        let annualIncome = monthlyIncomeTotal * 12
        let annualExpenses = monthlyExpenseTotal * 12
        let annualNet = annualIncome - annualExpenses
        annualNetTotal = annualNet
        annualCashflowText = formatCurrency(annualNet)
        annualCashflowSubtitleText = ""
        annualCashflowIsPositive = annualNet >= 0
    }

    // MARK: - Helper Methods

    private func formatCurrency(_ value: Double) -> String {
        let absVal = abs(value)
        let sign = value < 0 ? "-" : ""
        let (num, suffix): (Double, String) = {
            if absVal >= 1_000_000 { return (absVal / 1_000_000, "m") }
            if absVal >= 1_000 { return (absVal / 1_000, "k") }
            return (absVal, "")
        }()
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = suffix.isEmpty ? 0 : 2
        let core = formatter.string(from: NSNumber(value: num)) ?? "\(num)"
        return "\(sign)$\(core)\(suffix)"
    }
    
    var totalEquity: Double {
        properties.reduce(0) { $0 + $1.equity }
    }
    
    var propertyAllocationPercentage: Double {
        guard totalPortfolioValue > 0 else { return 0 }
        return (totalPropertyValue / totalPortfolioValue) * 100
    }
    
    var shareAssets: [Asset] {
        assets.filter { $0.type == "shares" }
    }
    
    var cashAssets: [Asset] {
        assets.filter { $0.type == "cash" }
    }
    
    var otherAssets: [Asset] {
        assets.filter { $0.type == "other" }
    }

    // MARK: - Cashflow helpers
    private func calculateCashflow() {
        monthlyIncomeTotal = 0
        monthlyExpenseTotal = 0

        // Property cashflow
        for property in properties {
            let monthlyIncome = property.rentalIncome * 52 / 12
            let mgmt = (property.managementFeePercent / 100) * monthlyIncome
            let baseExpenses = property.expensesAreMonthly ? property.estimatedExpensesAmount : property.estimatedExpensesAmount / 12
            let mortgage = property.loan?.monthlyRepayment ?? 0
            let insurance = monthlyInsurance(for: property)

            monthlyIncomeTotal += monthlyIncome
            monthlyExpenseTotal += mgmt + baseExpenses + mortgage + insurance
        }

        // Liabilities (non-property)
        let liabilityPayments = liabilities.reduce(0) { $0 + max($1.minimumPayment, 0) }
        monthlyExpenseTotal += liabilityPayments
    }

    private func monthlyInsurance(for property: Property) -> Double {
        guard let insurance = property.insurance else { return 0 }
        if insurance.sameProvider {
            // Combined policy should only be counted once; assume building values carry the shared premium.
            return max(insurance.buildingMonthlyRepayment, insurance.landlordMonthlyRepayment)
        }
        return insurance.buildingMonthlyRepayment + insurance.landlordMonthlyRepayment
    }
    
    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }
}
