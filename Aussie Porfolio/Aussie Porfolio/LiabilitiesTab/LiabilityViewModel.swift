import Foundation
import RealmSwift
internal import Realm

final class LiabilityViewModel {
    private let realm = try! Realm()
    private(set) var liabilities: [Liability] = [] {
        didSet { onLiabilitiesChanged?() }
    }
    private var notificationToken: NotificationToken?

    var onLiabilitiesChanged: (() -> Void)?

    init() {
        loadLiabilities()
        observeChanges()
    }

    private func loadLiabilities() {
        let results = realm.objects(Liability.self).sorted(byKeyPath: "createdAt", ascending: false)
        liabilities = Array(results)
    }

    private func observeChanges() {
        notificationToken = realm.objects(Liability.self).observe { [weak self] _ in
            self?.loadLiabilities()
        }
    }

    func addLiability(_ liability: Liability) {
        try? realm.write {
            realm.add(liability)
        }
    }

    func updateLiability(_ liability: Liability, name: String, type: String, balance: Double, interestRate: Double, minimumPayment: Double, dueDate: Date?, notes: String) {
        try? realm.write {
            liability.name = name
            liability.type = type
            liability.balance = balance
            liability.interestRate = interestRate
            liability.minimumPayment = minimumPayment
            liability.dueDate = dueDate
            liability.notes = notes
            liability.updatedAt = Date()
        }
    }

    func deleteLiability(_ liability: Liability) {
        try? realm.write {
            realm.delete(liability)
        }
    }

    deinit {
        notificationToken?.invalidate()
    }

    // MARK: - Computed Properties

    var totalBalance: Double {
        return liabilities.reduce(0) { $0 + $1.balance }
    }

    var totalBalanceText: String {
        return "$\(Int(totalBalance).formattedWithSeparator())"
    }

    var liabilitiesCountText: String {
        return "\(liabilities.count) liability\(liabilities.count == 1 ? "" : "ies")"
    }
}
