import Foundation
import RealmSwift
internal import Realm

final class CashAccountViewModel {
    private let realm = try! Realm()
    private(set) var cashAccounts: [CashAccount] = [] {
        didSet { onCashAccountsChanged?() }
    }
    private var notificationToken: NotificationToken?

    var onCashAccountsChanged: (() -> Void)?

    init() {
        loadCashAccounts()
        observeChanges()
    }

    private func loadCashAccounts() {
        let results = realm.objects(CashAccount.self).sorted(byKeyPath: "createdAt", ascending: false)
        cashAccounts = Array(results)
    }

    private func observeChanges() {
        notificationToken = realm.objects(CashAccount.self).observe { [weak self] _ in
            self?.loadCashAccounts()
        }
    }

    func addCashAccount(_ account: CashAccount) {
        try? realm.write {
            realm.add(account)
        }
    }

    func updateCashAccount(_ account: CashAccount, name: String, accountType: String, balance: Double, interestRate: Double, institution: String, notes: String) {
        try? realm.write {
            account.name = name
            account.accountType = accountType
            account.balance = balance
            account.interestRate = interestRate
            account.institution = institution
            account.notes = notes
            account.updatedAt = Date()
        }
    }

    func deleteCashAccount(_ account: CashAccount) {
        try? realm.write {
            realm.delete(account)
        }
    }

    deinit {
        notificationToken?.invalidate()
    }

    // MARK: - Computed Properties

    var totalBalance: Double {
        return cashAccounts.reduce(0) { $0 + $1.balance }
    }

    var totalBalanceText: String {
        return "$\(Int(totalBalance).formattedWithSeparator())"
    }

    var accountsCountText: String {
        return "\(cashAccounts.count) account\(cashAccounts.count == 1 ? "" : "s")"
    }
}
