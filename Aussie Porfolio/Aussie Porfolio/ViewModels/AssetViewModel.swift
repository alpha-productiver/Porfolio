import Foundation
import RealmSwift

final class AssetViewModel {
    private let realm = try! Realm()
    private(set) var assets: [Asset] = [] {
        didSet { onAssetsChanged?() }
    }
    private var notificationToken: NotificationToken?

    var onAssetsChanged: (() -> Void)?

    init() {
        loadAssets()
        observeChanges()
    }

    private func loadAssets() {
        let results = realm.objects(Asset.self).sorted(byKeyPath: "createdAt", ascending: false)
        assets = Array(results)
    }

    private func observeChanges() {
        notificationToken = realm.objects(Asset.self).observe { [weak self] _ in
            self?.loadAssets()
        }
    }

    func addAsset(_ asset: Asset) {
        try? realm.write {
            realm.add(asset)
        }
    }

    func updateAsset(_ asset: Asset, name: String, type: String, value: Double, quantity: Double, purchasePrice: Double, notes: String) {
        try? realm.write {
            asset.name = name
            asset.type = type
            asset.value = value
            asset.quantity = quantity
            asset.purchasePrice = purchasePrice
            asset.notes = notes
            asset.updatedAt = Date()
        }
    }

    func deleteAsset(_ asset: Asset) {
        try? realm.write {
            realm.delete(asset)
        }
    }

    deinit {
        notificationToken?.invalidate()
    }

    // MARK: - Computed Properties

    var totalValue: Double {
        return assets.reduce(0) { $0 + $1.value }
    }

    var totalValueText: String {
        return "$\(Int(totalValue).formattedWithSeparator())"
    }

    var assetsCountText: String {
        return "\(assets.count) asset\(assets.count == 1 ? "" : "s")"
    }

    var totalGainLoss: Double {
        return assets.reduce(0) { $0 + $1.gainLoss }
    }

    var totalGainLossText: String {
        let gain = totalGainLoss
        let sign = gain >= 0 ? "+" : ""
        return "\(sign)$\(Int(abs(gain)).formattedWithSeparator())"
    }
}
