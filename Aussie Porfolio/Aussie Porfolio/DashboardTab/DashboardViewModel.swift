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
    
    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }
}
